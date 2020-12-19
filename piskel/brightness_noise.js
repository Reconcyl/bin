// make parts of the image brighter or darker

{
  const N = 16;

  function smoothNoise(r, t) {
    const nums = [];
    for (let i = 0; i < N*N; i++) {
      nums.push(Math.random());
    }
    function get(x, y) {
      x = ((x % N) + N) % N;
      y = ((y % N) + N) % N;
      return nums[y * N + x];
    }
    for (let i = 0; i < t; i++) {
      for (let y = 0; y < N; y++) {
        for (let x = 0; x < N; x++) {
          let total = get(x, y);
          total += get(x - 1, y) * r;
          total += get(x + 1, y) * r;
          total += get(x, y - 1) * r;
          total += get(x, y + 1) * r;
          nums[y * N + x] = total / (1 + 4 * r);
        }
      }
    }
    return get;
  }

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

  const get = smoothNoise(1, 3);
  for (let x = 0; x < N; x++) {
    for (let y = 0; y < N; y++) {
      const r = get(x, y);
      let value = 20 * 2 * Math.abs(r - 0.5);
      if (r < 0.5) {
        modifyPixel(x, y, c => tinycolor.lighten(c, value));
      } else {
        modifyPixel(x, y, c => tinycolor.darken(c, value));
      }
    }
  }
}