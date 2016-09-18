'use strict';

import React from 'react';

require('styles//Search.css');

var $ = require('jquery');

var SearchBar = React.createClass({
  componentDidMount(){
    var x = new XMLHttpRequest();
    var timesToTextMap = new Map();
      x.open("GET", "https://www.youtube.com/api/timedtext?&lang=en&v=zGb9smintY0", true);
      x.onreadystatechange = function () {
        if (x.readyState == 4 && x.status == 200)
        {
          var xmlDoc = x.responseXML;
          var textElements = xmlDoc.getElementsByTagName("transcript")[0].getElementsByTagName("text");

          console.log("textElements = ", textElements);
          console.log("textElements.constructor = ", textElements.constructor);

          console.log("textElements.item(2) = ", textElements.item(2));

          for (var i = 0; i < textElements.length; i++) {
            var text = textElements.item(i).textContent;
            var start = textElements.item(i).attributes.getNamedItem("start").value;

            timesToTextMap.set(start, text);
          }
        }
      };

      console.log("timesToTextMap = ", timesToTextMap);
      x.send(null);
  },

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

var SearchComponent = new React.createClass({
  getInitialState(){
    return {
      phraseText: '',
      videoLink: ''
    };
  },

  handleUserInput(phraseText, videoLink) {
    this.setState({
      phraseText: phraseText,
      videoLink: videoLink
    });
    console.log('phrase: ' + phraseText);
    console.log('video: '+ videoLink)
  },

  scrob(){

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