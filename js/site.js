const possibleBackgrounds = [{background: "/static/dubabin-60.svg", size: "5%"}, {background: "/static/dubabin-75.svg", size: "2.5%"}];
const daysSinceEpoch = Math.floor(Date.now() / 86400000);
// pick background based on day, so that it is stable (doesn't
// change at every page reload), but still changes reliably
const backgroundIndex = daysSinceEpoch % possibleBackgrounds.length;
const backgroundUrl = possibleBackgrounds[backgroundIndex].background;
const backgroundSize = possibleBackgrounds[backgroundIndex].size;
const rootElement = document.documentElement;
rootElement.style['background-image'] = `url(${backgroundUrl})`;
rootElement.style['background-size'] = backgroundSize;
