'use strict';

import React from 'react';

require('styles//Search.css');
require('reqwest');

var parseString = require('xml2js').parseString;
var $ = require('jquery');

var SearchBar = React.createClass({
  componentDidMount(){
    $.ajax({
      url: 'https://www.youtube.com/api/timedtext?&lang=en&v=zGb9smintY0',
      dataType: 'xml',
      success: function(xml) {
        var xmlDoc = $.parseXML( xml ),
        $xml = $( xmlDoc ),
        $text = $xml.find( 'text' );
        console.log($text.text());
      }
    });
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
