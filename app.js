
/**
 * Module dependencies.
 */

var express = require('express')
  , routes = require('./routes')
  , user = require('./routes/user')
  , http = require('http')
  , path = require('path');

var app = express();

BASE_PATH = process.cwd();

require(BASE_PATH + '/vendor/Neon.js');
require(BASE_PATH + '/vendor/CustomEvent.js');
require(BASE_PATH + '/vendor/CustomEventSupport.js');
require(BASE_PATH + '/vendor/NodeSupport.js');
require(BASE_PATH + '/polonium.js');

// all environments
app.set('port', process.env.PORT || 3000);
app.set('views', __dirname + '/views');
app.set('view engine', 'jade');
app.use(express.favicon());
app.use(express.logger('dev'));
app.use(express.bodyParser());
app.use(express.methodOverride());
app.use(app.router);
app.use(express.static(path.join(__dirname, 'public')));

// development only
if ('development' == app.get('env')) {
  app.use(express.errorHandler());
}

app.get('/', routes.index);

polonium = new Polonium();

app.get('/get_request_token', function (req, res) {
    polonium.getRequestToken( req, res );
});

app.get('/authorize', function (req, res) {
	polonium.authorize( req, res);
});

http.createServer(app).listen(app.get('port'), function(){
  console.log('Express server listening on port ' + app.get('port'));
});
