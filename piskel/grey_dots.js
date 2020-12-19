// create gray dots in random places

{
  function modifyPixel(x, y, f) {
    let frame = pskl.app.piskelController.getCurrentFrame();
    let color = frame.getPixel(x, y);
    color = pskl.utils.intToColor(color);
    color = tinycolor(color);
    if (!color.ok) throw "not ok";
    color = f(color);
    if (!color.ok) throw "not ok";
    frame.setPixel(x, y, pskl.utils.colorToInt(color));
    return color;
  }

  function grayDot(x, y) {
    modifyPixel(x, y, c => tinycolor.lighten(tinycolor.greyscale(c)))
  }

  grayDot(1, 3);
  grayDot(13, 2);
  grayDot(4, 6);
  grayDot(13, 7);
  grayDot(14, 10);
  grayDot(8, 11);
  grayDot(6, 15);
  grayDot(12, 15);
}