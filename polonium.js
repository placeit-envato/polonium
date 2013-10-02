Class('Polonium')({

	prototype : {

		getRequestToken : function (req, res) {

		},

		authorize : function (req, res) {

		},

		callback : function (req, res) {

		},

		badRequest : function (req, res) {
			// callback : req.params.callback ????
			return {error : "Bad Request", code : 400, callback : null};
		},

		notAuthorizedApiCall : function (req, res) {
			return {error : "Unauthorized", code : 401, callback : null};
		},

		notEnoughRequests : function (req, res) {
			return {error : "Not Enough Requests", code : 401, callback : null};
		}


	}
});