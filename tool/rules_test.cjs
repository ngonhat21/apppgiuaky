// npm install --prefix ../work/npm @firebase/util
// Start Realtime Database Emulator on 127.0.0.1:9000 before running.
const fs = require('node:fs');
const assert = require('node:assert/strict');
const {createMockUserToken} = require('@firebase/util');
const root='http://127.0.0.1:9000';
const project='demo-apppgiuaky';
async function request(path, method, body, uid) {
 const token=uid ? '&auth='+createMockUserToken({sub:uid},project) : '';
 return fetch(`${root}/${path}.json?ns=${project}${token}`, {method, ...(body === undefined ? {} : {body:JSON.stringify(body)}), signal:AbortSignal.timeout(10000)});
}
(async()=>{
 const rules=fs.readFileSync('database/database.rules.json','utf8').replaceAll('REPLACE_WITH_ADMIN_UID','admin-test');
 const loaded=await fetch(`${root}/.settings/rules.json?ns=${project}`,{method:'PUT',headers:{Authorization:'Bearer owner'},body:rules});
 assert.equal(loaded.status,200,await loaded.text());
 const p={name:'Test',price:100,soluong:3,image:'data:image/png;base64,aA=='};
 const checks=[
  ['admin create','products/rules-test','PUT',p,'admin-test',200],
  ['admin read','products','GET',undefined,'admin-test',200],
  ['other cannot read','products','GET',undefined,'other-user',401],
  ['anonymous cannot read','products','GET',undefined,undefined,401],
  ['other cannot write','products/rules-test','PUT',p,'other-user',401],
  ['reject extra field','products/rules-test','PUT',{...p,extra:'no'},'admin-test',401],
  ['reject negative price','products/rules-test','PUT',{...p,price:-1},'admin-test',401],
  ['reject fractional quantity','products/rules-test','PUT',{...p,soluong:1.5},'admin-test',401],
  ['reject missing field','products/rules-test','PUT',{name:'Missing',price:1,soluong:1},'admin-test',401],
  ['admin update','products/rules-test','PUT',{...p,price:200},'admin-test',200],
  ['admin delete','products/rules-test','DELETE',undefined,'admin-test',200]
 ];
 for(const [label,path,method,body,uid,status] of checks){const r=await request(path,method,body,uid);assert.equal(r.status,status,label+': '+await r.text());console.log('PASS '+label);}
 console.log('11 Firebase Rules checks passed (local emulator).');
})().catch(e=>{console.error(e);process.exitCode=1;});
