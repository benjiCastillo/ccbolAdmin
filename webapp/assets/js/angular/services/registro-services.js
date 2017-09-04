var app = angular.module('ccbolApp.registroServices',[])

app.factory('registroServices', ['$http','$q','$rootScope', function($http,$q,$rootScope){

	var self ={
		guardarEst : function(datos){
					var d = $q.defer();
					// console.log(datos);
                    $http({
                      method: 'POST',
					  	url: 'http://192.168.1.3/ccbolAdmin/api/public/user/adminLogin/',
 						data: datos
                    	})
                        .then(function successCallback(response) {
								// console.log(response.data);
								self.response 	= response.data;
								
								return d.resolve()	
                            }, function errorCallback(response) {
								
								self.response 	= response.data
								return d.resolve();
                        });
                       return d.promise;	 
		},
		getUserData : function(datos){
					var d = $q.defer();
					// console.log(datos);
                    $http({
                      method: 'GET',
					  	url: 'http://192.168.1.3/ccbolAdmin/api/public/user/listUserBc/'+datos
                    	})
                        .then(function successCallback(response) {
								// console.log(response.data);
								self.response 	= response.data;
								
								return d.resolve()	
                            }, function errorCallback(response) {
								
								self.response 	= response.data
								return d.resolve();
                        });
                       return d.promise;	 
		},
		updateUserData : function(datos){
					var d = $q.defer();
					// console.log(datos);
                    $http({
                      method: 'POST',
						  url: 'http://192.168.1.3/ccbolAdmin/api/public/user/updateUser/',
						  data: datos
                    	})
                        .then(function successCallback(response) {
								// console.log(response.data);
								self.response 	= response.data;
								
								return d.resolve()	
                            }, function errorCallback(response) {
								
								self.response 	= response.data
								return d.resolve();
                        });
                       return d.promise;	 
		},
		loginUser : function(datos){
					var d = $q.defer();
					// console.log(datos);
                    $http({
                          method: 'POST',
						  url: 'http://192.168.1.3/ccbolAdmin/api/public/user/adminLogin/',
						  data: datos
                    	})
                        .then(function successCallback(response) {
								// console.log(response.data);
								self.response 	= response.data;
								
								return d.resolve()	
                            }, function errorCallback(response) {
								
								self.response 	= response.data
								return d.resolve();
                        });
                       return d.promise;	 
		},	
		userPaidBc : function(datos){
					var d = $q.defer();
					// console.log(datos);
                    $http({
                          method: 'POST',
						  url: 'http://192.168.1.3/ccbolAdmin/api/public/user/userPaidBc/',
						  data: datos
                    	})
                        .then(function successCallback(response) {
								// console.log(response.data);
								self.response 	= response.data;
								
								return d.resolve()	
                            }, function errorCallback(response) {
								
								self.response 	= response.data
								return d.resolve();
                        });
                       return d.promise;	 
		}														

	}


	return self;
}])
