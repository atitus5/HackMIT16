'use strict';

import React from 'react';

require('styles//Search.css');

var $ = require('jquery');

var SearchBar = React.createClass({
  handleChange() {
    this.props.onUserInput(
      this.refs.phraseTextInput.value,
      this.refs.videoLinkInput.value
    );
  },

  render() {
    return (
      <div className="search-component">
        <form>
          <input
            type="text"
            placeholder="Phrase..."
            value={this.props.phraseText}
            ref="phraseTextInput"
            onChange={this.handleChange}
          />
          <input
            type="text"
            placeholder="Search..."
            value={this.props.videoLink}
            ref="videoLinkInput"
            onChange={this.handleChange}
          />
        </form>
      </div>
    );
  }
});

var watchUrlToXmlUrl = function(watchUrl) {
    return 'https://www.youtube.com/api/timedtext?&lang=en&v=' + watchUrl.split("v=")[1];
  };

  var getTimesMapFromXmlUrl = function(xmlUrl) {
    var x = new XMLHttpRequest();
    var timesToTextMap = new Map();
      x.open("GET", xmlUrl, false);
      x.onreadystatechange = function () {
        if (x.readyState == 4 && x.status == 200)
        {
          var xmlDoc = x.responseXML;
          var textElements = xmlDoc.getElementsByTagName("transcript")[0].getElementsByTagName("text");

          for (var i = 0; i < textElements.length; i++) {
            var text = textElements.item(i).textContent;
            var start = textElements.item(i).attributes.getNamedItem("start").value;

            timesToTextMap.set(start, text);
          }
        }
      };
      x.send(null);

      return timesToTextMap;
  };

  var getTimesOfPhrase = function(dictionary, phrase) {
    phrase = phrase.toLowerCase().trim(); // Sanitize
    var timesOfPhraseArray = new Array();

    dictionary.forEach(function(value, key, map){
      if (value.includes(phrase)) {
        timesOfPhraseArray.push(key);
      };
    });
    
    return timesOfPhraseArray;
  };

  var convertTimesToUrls = function(phraseTimesMap, originalUrl) {
    var matchedWatchUrlsMap = new Array();

    phraseTimesMap.forEach(function(time) {
      var watchUrl = originalUrl + "&t=" + parseInt(time).toString() + "s";
      matchedWatchUrlsMap.push(watchUrl);
    });

    return matchedWatchUrlsMap;
  }

var SearchComponent = new React.createClass({
  getInitialState(){
    return {
      phraseText: 'open',
      videoLink: 'https://www.youtube.com/watch?v=zGb9smintY0'
    };
  },

  handleUserInput(phraseText, videoLink) {
    this.setState({
      phraseText: phraseText,
      videoLink: videoLink
    });
  },

  scrub(){
    // Get the XML url
    var xmlUrl = watchUrlToXmlUrl(this.state.videoLink);
    var timesMap = getTimesMapFromXmlUrl(xmlUrl);
    var phraseTimesMap = getTimesOfPhrase(timesMap, this.state.phraseText);
    var matchedWatchUrlsArray = convertTimesToUrls(phraseTimesMap, this.state.videoLink);
    console.log("matchedWatchUrlsMap=",matchedWatchUrlsArray);
  },

  render() {
    return (
      <div className="search-component">
        <SearchBar
          phraseText={this.state.phraseText}
          videoLink={this.state.videoLink}
          onUserInput={this.handleUserInput}
        />
        <button onClick={this.scrub}>Scrub</button>
      </div>
    );
  }
});

SearchComponent.displayName = 'SearchComponent';

// Uncomment properties you need
// SearchComponent.propTypes = {};
// SearchComponent.defaultProps = {};

export default SearchComponent;