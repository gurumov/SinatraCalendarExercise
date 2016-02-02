

openModal = function(date) {
  var modal = document.getElementById("EventModal");
  modal.style.visibility = "visible";
  document.getElementById("dselect").setAttribute("value", date);
};

closeModal = function() {
  var modal = document.getElementById("EventModal");
  modal.style.visibility = "hidden";
};

changeGroup = function() {
  var select = document.getElementById("groupSelect");
  window.location = "/groupsView/".concat(select.value);
};

checkIt = function() {
  var box = document.getElementById("CompactView");
  box.value = "on";
};

drop = function() {
  var menu = document.getElementById("drpdown");
  menu.style.display = "block";
};

openGroupModal = function() {
  var modal = document.getElementById("GroupModal");
  modal.style.visibility = "visible";
};

closeGroupModal = function() {
  var modal = document.getElementById("GroupModal");
  modal.style.visibility = "hidden";
};
