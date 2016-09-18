'use strict';

import React from 'react';
import { Route, IndexRedirect } from 'react-router';

import App from './Main';
import SearchComponent from './SearchComponent.js';
import LinkComponent from './LinkComponent.js';

module.exports = (
    <Route path="/" component={App}>
        <IndexRedirect to="/search" />
        <Route path='search' component={SearchComponent}/>
        <Route path='links' component={LinkComponent} />
    </Route>
)
