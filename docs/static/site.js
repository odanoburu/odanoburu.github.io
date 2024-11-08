
{ /* Set background */
  const possibleBackgrounds = [
    {background: "/static/dubabin-60.svg", size: "5%"},
    {background: "/static/dubabin-75.svg", size: "2.5%"},
    {background: "/static/dubabin-298-A.svg", size: "5%"},
  ];
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


{ /* Post filtering */
  // HARDCODED constants
  const keywordsMenu = document.getElementById("keywords-menu");

  if (keywordsMenu) { // We are at the at a page that needs a keywords menu
    const posts = document.querySelectorAll('.post');
    // hardcoded names
    const filterParam = 'filter';
    const noDisplayClass = 'nodisplay';
    const selectedClass = 'selected';
    const optionClass = 'option';

    // add element to clear all filters
    let clearElem = document.createElement("li");
    clearElem.classList.add(optionClass);
    clearElem.style['font-style'] = "italic";
    clearElem.style['font-size'] = "0.8em";
    const clearText = document.createTextNode("[clear]");
    clearElem.appendChild(clearText);
    clearElem.addEventListener('click', event => {
      clearKeywordFilter();
      kwElems.forEach((kwElem) => kwElem.classList.remove(selectedClass));
      posts.forEach((post) => post.classList.remove(noDisplayClass));
    });
    keywordsMenu.appendChild(clearElem);

    let keywordFilters = new Set(); // stores the active keyword filters
    let url = new URL(location.href);
    let urlSearchParams = new URLSearchParams(url.search);
    const syncKeywordsFiltersWithURL = () => {
      const activeFilterKws = urlSearchParams.getAll(filterParam);
      keywordFilters = new Set(activeFilterKws);
    };
    syncKeywordsFiltersWithURL();
    const getKeywordElemPosts = (kw) => {
      const kwElem = document.querySelector(`#keywords-menu > li.option[data-keyword="${kw}"]`);
      const filteredPosts = document.querySelectorAll(`.post:not([data-keyword~="${kw}"])`);
      return {kwElem: kwElem, filteredPosts: filteredPosts};
    };
    /* we need the following two functions separately because when
     we load a URL with an active filter the keyword is already
     there but no filtering is being done */
    const filterKeyword = (kw) => {
      let {kwElem, filteredPosts} = getKeywordElemPosts(kw);
      kwElem.classList.add(selectedClass);
      filteredPosts.forEach(post => {
        post.classList.add(noDisplayClass);
      });
    };
    const addKeywordFilter = (kw) => {
      keywordFilters.add(kw);
      urlSearchParams.append(filterParam, kw);
      url.search = urlSearchParams.toString();
      history.pushState(null, '', url);
    };
    const removeKeywordFilter = (kw) => {
      keywordFilters.delete(kw);
      const activeFilterKws = urlSearchParams.getAll(filterParam);
      const newActiveFilterKws = activeFilterKws.filter((akw) => akw != kw);
      urlSearchParams.delete(filterParam);
      newActiveFilterKws.forEach((kw) => urlSearchParams.append(filterParam, kw));
      url.search = urlSearchParams.toString();
      history.pushState(null, '', url);
    };
    const clearKeywordFilter = () => {
      keywordFilters.clear();
      urlSearchParams.delete(filterParam);
      url.search = urlSearchParams.toString();
      history.pushState(null, '', url);
    };

    // get posts unique keywords and sort by frequency
    let keywordsFrequency = new Map();
    posts.forEach((p) => {
      // fill map
      p.getAttribute('data-keyword').split(" ").forEach((k) => keywordsFrequency.set(k, 1 + (keywordsFrequency.get(k) || 0)));
    });
    const sortedKeywords = [...keywordsFrequency.entries()].sort(([k, freq], [k_, freq_]) => freq_ - freq).map(([attr, _freq]) => attr);

    const toggleFilter = (kw) => {
      const filterActive = keywordFilters.has(kw);
      if (filterActive) { // deactivate it, and show any posts that are not filtered anymore
	removeKeywordFilter(kw);
	let {kwElem, filteredPosts} = getKeywordElemPosts(kw);
	kwElem.classList.remove(selectedClass);
        filteredPosts.forEach(post => {
          const postKeywords = post.getAttribute('data-keyword').split(" ");
          if (Array.from(keywordFilters.values()).every(filteredKw => postKeywords.some(postKw => postKw === filteredKw))) {
            // no other filter for post is active, so remove
            post.classList.remove(noDisplayClass);
          }
        });
      } else { // activate filter
	addKeywordFilter(kw);
	filterKeyword(kw);
      }
    };

    // create the HTML elements that will toggle the keyword filters
    // on and off
    const kwElems = sortedKeywords.map(kw => {
      let kwElem = document.createElement("li");
      kwElem.classList.add(optionClass);
      kwElem.setAttribute("data-keyword", kw);
      const text = document.createTextNode(kw);
      kwElem.appendChild(text);
      // when user clicks on keyword it toggles its filter
      kwElem.addEventListener('click', event => {
	toggleFilter(kw);
      });
      keywordsMenu.appendChild(kwElem);
      return kwElem;
    });
    // toggle filter for already active filters (those loaded from
    // the URL params)
    keywordFilters.forEach((kw) => filterKeyword(kw));
  }
}
