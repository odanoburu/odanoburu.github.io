
{ /* Set background */
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
}
/* */

/* Post filtering */
const keywordsMenu = document.getElementById("keywords-menu"); // the keywords menu element
if (keywordsMenu) {
    // We are at the at a page that needs a keywords menu

    // get posts unique keywords and sort by frequency
    const posts = document.querySelectorAll('.post');
    let keywordsFrequency = new Map();
    posts.forEach((p) => {
	// fill map
	p.getAttribute('data-keyword').split(" ").forEach((k) => keywordsFrequency.set(k, 1 + (keywordsFrequency.get(k) || 0)));
    });
    const sortedKeywords = [...keywordsFrequency.entries()].sort(([k, freq], [k_, freq_]) => freq_ - freq).map(([attr, _freq]) => attr);

    const noDisplayClass = "nodisplay";
    const selectedClass = "selected";
    const optionClass = "option";
    let keywordFilters = new Set(); // store the active keyword filters
    const kwElems = sortedKeywords.map(kw => {
	let kwElem = document.createElement("li");
	kwElem.classList.add(optionClass);
	const text = document.createTextNode(kw);
	kwElem.appendChild(text);
	kwElem.addEventListener('click', event => {
	    const filterActive = keywordFilters.has(kw);
	    const filteredPosts = document.querySelectorAll(`.post:not([data-keyword~="${kw}"])`);
	    if (filterActive) { // deactivate it, and show any posts that are not filtered anymore
		keywordFilters.delete(kw);
		kwElem.classList.remove(selectedClass);
		filteredPosts.forEach(post => {
		    const postKeywords = post.getAttribute('data-keyword').split(" ");
		    if (Array.from(keywordFilters.values()).every(filteredKw => postKeywords.some(postKw => postKw === filteredKw))) {
			// no other filter for post is active, so remove
			post.classList.remove(noDisplayClass);
		    }
		});
	    } else { // activate filter
		keywordFilters.add(kw);
		kwElem.classList.add(selectedClass);
		filteredPosts.forEach(post => {
		    post.classList.add(noDisplayClass);
		});
	    }
	});
	keywordsMenu.appendChild(kwElem);
	return kwElem;
    });
    let clearElem = document.createElement("li");
    clearElem.classList.add(optionClass);
    clearElem.style['font-style'] = "italic";
    clearElem.style['font-size'] = "0.8em";
    const clearText = document.createTextNode("[clear]");
    clearElem.appendChild(clearText);
    clearElem.addEventListener('click', event => {
	keywordFilters.clear();
	kwElems.forEach(kwElem => kwElem.classList.remove(selectedClass));
	posts.forEach(post => post.classList.remove(noDisplayClass));
    });
    keywordsMenu.appendChild(clearElem);
}
