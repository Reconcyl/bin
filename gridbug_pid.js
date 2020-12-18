// This code can be run on <http://nethack.gridbug.de/prices.html>
// to enable a number of key shortcuts:
//
// - 'b' to denote buying
// - 's' to denote selling
// - '?' to denote a scroll
// - '!' to denote a potion
// - '=' to denote a ring
// - '/' to denote a wand
// - '+' to denote a spellbook
// - 'p' to focus on the price field

(function() {
  let buyOrSell = document.getElementsByName("buy_or_sell");
  let objClassOptions = document.getElementsByName("object_class")[0];
  function focusPrice() {
    let price = form1.shk_price;
    price.focus();
    price.selectionStart = price.selectionEnd = price.value.length;
  }

  addEventListener("keydown", function(e) {
    if (e.ctrlKey || e.altKey || e.metaKey) return;
    switch (e.key) {
      case "b":
        buyOrSell[0].checked = true;
        break;
      case "s":
        buyOrSell[1].checked = true;
        break;
      case "?":
        objClassOptions[0].selected = true;
        focusPrice();
        break;
      case "!":
        objClassOptions[1].selected = true;
        focusPrice();
        break;
      case "=":
        objClassOptions[2].selected = true;
        focusPrice();
        break;
      case "/":
        objClassOptions[3].selected = true;
        focusPrice();
        break;
      case "+":
        objClassOptions[4].selected = true;
        focusPrice();
        break;
      case "p":
        focusPrice();
        break;
      default:
        return;
    }
    e.preventDefault();
  });
})();

// Minified:
// (_=>{let b=document.getElementsByName("buy_or_sell"),o=document.getElementsByName("object_class")[0],p=form1.shk_price,f=_=>{p.focus();p.selectionStart=0;p.selectionEnd=p.value.length},s=i=>f(o[i].selected=true);addEventListener("keydown",function(e){if(e.ctrlKey||e.altKey||e.metaKey)return;switch(e.key){case"b":b[0].checked=true;break;case"s":b[1].checked=true;break;case"?":s(0);break;case"!":s(1);break;case"=":s(2);break;case"/":s(3);break;case"+":s(4);break;case"p":f();break;default:return}e.preventDefault()})})()