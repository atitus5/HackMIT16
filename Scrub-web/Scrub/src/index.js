import 'core-js/fn/object/assign';
import React from 'react';
import ReactDOM from 'react-dom';
import {Router, browserHistory} from 'react-router';

import routes from './components/routes.js';


// Render the main component into the dom
//ReactDOM.render(<App />, document.getElementById('app'));
ReactDOM.render(
    <Router routes={routes} history={browserHistory} />,
     document.getElementById('app'));
