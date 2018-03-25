function Run1() {
  Utils.run_command("xdg-open http://blankonlinux.or.id");
}
function Run2() {
  Utils.run_command("xdg-open http://panduan.blankonlinux.or.id");
}
function Run3() {
  Utils.run_command("xdg-open https://facebook.com/groups/blankonlinux");
}
function Run4() {
  Utils.run_command("xdg-open https://twitter.com/BlankOnLinux/");
}
function Play(){
  Utils.run_command("audacious -p");
}
function Stop(){
  Utils.run_command("audtool shutdown");
}
function Prev(){
  Utils.run_command("audacious -r");
}
function Next(){
  Utils.run_command("audacious -f");
}
function Pause(){
  Utils.run_command("audacious -u");
}
function Repeat(){
  Utils.run_command("audtool --playlist-repeat-toggle");
}

// Gnome Control Center

function RunWallpaper() {
  Utils.run_command("gnome-control-center background");
}
function RunAccount() {
  Utils.run_command("gnome-control-center user-accounts");
}
function RunSound() {
  Utils.run_command("gnome-control-center sound");
}
function RunInfo() {
  Utils.run_command("gnome-control-center info-overview");
}
function RunBluetooth() {
  Utils.run_command("gnome-control-center bluetooth");
}
function RunRegional() {
  Utils.run_command("gnome-control-center region");
}
function RunKeyboard() {
  Utils.run_command("gnome-control-center keyboard");
}
function RunPower() {
  Utils.run_command("gnome-control-center power");
}
function RunDate() {
  Utils.run_command("gnome-control-center datetime");
}
function RunDisplay() {
  Utils.run_command("gnome-control-center display");
}
function RunMouse() {
  Utils.run_command("gnome-control-center mouse");
}
function RunNetwork() {
  Utils.run_command("gnome-control-center network");
}
function RunOnline() {
  Utils.run_command("gnome-control-center online-accounts");
}
function RunPrinter() {
  Utils.run_command("gnome-control-center printers");
}
function RunShare() {
  Utils.run_command("gnome-control-center sharing");
}

$(document).ready(function() {
  $('#repeat').click(function(){
    if ($('#repeat').hasClass("selected")) { 
      $('#repeat').removeClass("selected");
    } else {
      $('#repeat').addClass("selected");
    }
  });
});

