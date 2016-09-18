'use strict';

import React from 'react';
import ReactList from 'react-list';

require('styles//Search.css');

var $ = require('jquery');

class LinkList extends React.Component{
  renderItem(index, key) {
    return <div key={key} className={'item' + (index % 2 ? '' : '_even')}f>
      <a href={this.props.links[index]} target="blank">{this.props.links[index].split("t=")[1]}</a>
    </div>;
  }

  render() {
    return (
      <div className="linklist-component">
        <ReactList
            itemRenderer={::this.renderItem}
            length={this.props.links.length}
            type='uniform'
        />
      </div>
    );
  }
};

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
        <p>Phrase</p>
        <form id="forms">
          <input
            type="text"
            placeholder="Phrase..."
            value={this.props.phraseText}
            ref="phraseTextInput"
            onChange={this.handleChange}
          />
        </form>
        <p>YouTube URL</p>
        <form id="forms2">
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
            var text = " " + textElements.item(i).textContent.toLowerCase();
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
      if (value.includes(" " + phrase)) {
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

$(document).keypress(function(e){
    if (e.which == 13){
        $("#scrub").click();
    }
});

var SearchComponent = new React.createClass({
  getInitialState(){
    return {
      phraseText: 'open',
      videoLink: 'https://www.youtube.com/watch?v=zGb9smintY0',
      links: [],
      showList: false
    };
  },

  componentDidMount(){
    document.getElementById('forms').addEventListener('submit', function(e) {
        e.preventDefault();
    }, false);
    document.getElementById('forms2').addEventListener('submit', function(e) {
        e.preventDefault();
    }, false);
  },

  handleUserInput(phraseText, videoLink) {
    this.setState({
      phraseText: phraseText,
      videoLink: videoLink
    });
    console.log("phrase: " + this.state.phraseText);
    console.log("video: " + this.state.videoLink);
    console.log("links: " + this.state.links);
  },

  scrub(){
    // Get the XML url
    var xmlUrl = watchUrlToXmlUrl(this.state.videoLink);
    var timesMap = getTimesMapFromXmlUrl(xmlUrl);
    var phraseTimesMap = getTimesOfPhrase(timesMap, this.state.phraseText);
    var matchedWatchUrlsArray = convertTimesToUrls(phraseTimesMap, this.state.videoLink);
    this.setState({
      links: matchedWatchUrlsArray,
      showList: true
    })
    console.log("matchedWatchUrlsMap=",matchedWatchUrlsArray);
  },

  render() {
    var disp='none';
    if(this.state.showList){
      disp='block';
    }
    return (
      <div className="search-component">
        <h1>Welcome to Scrub!</h1>
        <h7>Search YouTube by dialogue content with ease!</h7>
        <SearchBar
          phraseText={this.state.phraseText}
          videoLink={this.state.videoLink}
          onUserInput={this.handleUserInput}
        />
        <button id="scrub" onClick={this.scrub}>Scrub</button>
        <div style={{display: disp}}>
          <LinkList
            links={this.state.links} 
          />
        </div>
      </div>
    );
  }
});

SearchComponent.displayName = 'SearchComponent';

// Uncomment properties you need
// SearchComponent.propTypes = {};
// SearchComponent.defaultProps = {};

export default SearchComponent;