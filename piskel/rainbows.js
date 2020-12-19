// create a magic psychedelic pattern

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

  const getR = smoothNoise(1, 2);
  const getG = smoothNoise(1, 2);
  const getB = smoothNoise(1, 2);
  for (let x = 0; x < N; x++) {
    for (let y = 0; y < N; y++) {
      let color = tinycolor.fromRatio({
        r: getR(x, y),
        g: getG(x, y),
        b: getB(x, y),
      });
      modifyPixel(x, y, _ => color);
    }
  }
}