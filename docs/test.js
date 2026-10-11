const vm=require('node:vm'),fs=require('node:fs'),assert=require('node:assert/strict');
const elements=new Map();function element(){return {value:'',textContent:'',innerHTML:'',dataset:{},style:{},classList:{add(){},remove(){},toggle(){},contains(){return true}},addEventListener(){},focus(){},close(){},showModal(){}};}
const messages=[];const context=vm.createContext({console,Date,crypto:require('node:crypto').webcrypto,setTimeout(){},clearTimeout(){},setInterval(){},confirm:()=>true,prompt:()=>null,window:{webkit:{messageHandlers:{native:{postMessage:m=>messages.push(m)}}}},document:{querySelector:s=>{if(!elements.has(s))elements.set(s,element());return elements.get(s)},body:element(),addEventListener(){},activeElement:{tagName:'BODY'}}});
vm.runInContext(fs.readFileSync('src/app.js','utf8'),context);
function run(code){return vm.runInContext(code,context)}
run("view='planned';addTask('Repeat month-end');selected=state.tasks[0].id;updateTask('due','2026-01-31');updateTask('repeat','monthly');complete(selected)");
assert.equal(run('state.tasks[1].due'),'2026-02-28');assert.equal(run('state.tasks[1].completed'),false);
run("selected=state.tasks[1].id;addStep('First step');stepToggle(0);updateTask('notes','中文备注');updateTask('important',true);deleteTask(selected)");
assert.equal(run('state.tasks[1].deleted'),true);run('restore(state.tasks[1].id)');assert.equal(run('state.tasks[1].steps[0].done'),true);
assert.equal(run("matches(state.tasks[1],'important')"),true);run("query='中文'");assert.equal(run('visible().length'),1);
assert.equal(run('validBackup(state)'),true);assert.equal(run("validBackup({...state,tasks:[{...state.tasks[0],id:\"x');alert(1)//\"}]})"),false);
run('undo()');assert.equal(run('state.tasks[1].deleted'),true);
run("state.tasks[1].deleted=false;state.tasks[1].reminder='2000-01-01T09:00';state.tasks[1].reminded=false;checkReminders();checkReminders()");assert.equal(messages.filter(m=>m.action==='notify').length,1);
run("state.tasks=[];view='day';addTask('<img src=x onerror=alert(1)>')");assert.ok(run('row(state.tasks[0])').includes('&lt;img'));assert.ok(!run('row(state.tasks[0])').includes('<img'));
console.log('PASS: month-end recurrence, completion, steps, Unicode search, delete/restore, undo, backup validation, reminder deduplication, and HTML escaping.');
