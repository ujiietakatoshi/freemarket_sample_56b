

$(function(){

  // function appendUser() {
  //   var html = `<div class="add"><div><i class="fas fa-caret-up fa-2x"></div></i><div class="card back side image">カードの裏面をご参照ください<img alt="Flower" src="/assets/card-backside.png" width="240" height="105" margin="8px 0px 0px"/></div></div>`
  //   return html;
  // };




// $('.create__main__card-backside').on('click',function(e){
//   e.preventDefault();
//   $('.create__main__button').remove();
//   $('.create__main__card-backside').append(appendUser());
// });

// $('.create').on('click',function(e){
//   e.preventDefault();
//   $('.create__main__button').remove();
// });
});




// function HiddenCardBackside() {
//   var CardBackside	= document.getElementById("backside");
//   var AddButton = document.getElementById("addbutton");
//   if (CardBackside.className == "add"){
//     CardBackside.className = "hidden";
//     AddButton.className = "create__main__button"
//   }
// };

function ShowCardBackside() {

  var CardBackside	= document.getElementById("backside");
  var AddButton = document.getElementById("addbutton");
  if (CardBackside.className == "hidden"){
    CardBackside.className = "add";
    AddButton.className = "hidden"
  }else{
    CardBackside.className = "hidden";
    AddButton.className = "create__main__button"
  }
};