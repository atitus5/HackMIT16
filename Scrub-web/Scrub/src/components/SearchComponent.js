'use strict';

import React from 'react';

require('styles//Search.css');
require('reqwest');

var parseString = require('xml2js').parseString;
var $ = require('jquery');

var SearchBar = React.createClass({
  componentDidMount(){
    var timesMap = new Map();
    var x = new XMLHttpRequest();
      x.open("GET", "https://www.youtube.com/api/timedtext?&lang=en&v=zGb9smintY0", true);
      x.onreadystatechange = function () {
        if (x.readyState == 4 && x.status == 200)
        {
          var doc = x.responseXML;
          console.log("XML? = ", doc);
          console.log("XML type = ", doc.constructor);
          console.log("XML.element = ", doc.documentElement);
          console.log("XML type = ", doc.constructor);
          doc.documentElement.outerHTML.content("text").each(function (textDom) {
            //timesMap.set(textDom.attr);
          });
        }
      };
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