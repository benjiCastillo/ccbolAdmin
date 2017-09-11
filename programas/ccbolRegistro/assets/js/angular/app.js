var app = angular.module('ccbolApp',
	['ngRoute',
    'jcs-autoValidate',
    'ccbolApp.preinscripcionCtrl',
    'ccbolApp.preinscripcionServices'
    ]
	).run([
        'defaultErrorMessageResolver',
        function (defaultErrorMessageResolver) {
            // To change the root resource file path
            defaultErrorMessageResolver.setI18nFileRootPath('assets/js');
            defaultErrorMessageResolver.setCulture('es-co');

            /*defaultErrorMessageResolver.getErrorMessages().then(function (errorMessages) {
              errorMessages['coincide'] = 'Su contraseña no coincide';
              errorMessages['parse'] = 'Debe ingresar la nueva contraseña';
            });*/
        }
    ]);

    app.controller('mainCtrl', ['$scope','$http', function($scope,$http){

    }]);

 app.config( function ($routeProvider) {

	$routeProvider
	.when('/', {
		templateUrl: 'assets/js/angular/pages/preinscripcion.html',
        controller: 'preinscripcionCtrl'
	})
	// .when('/pre-inscripcion', {
	// 	templateUrl: 'assets/js/angular/pages/preinscripcion.html',
    //     controller: 'preinscripcionCtrl'
	// })            
	.otherwise({ 
		redirectTo: '/', 
	});
});

app.config(['$locationProvider', function($locationProvider) {
  $locationProvider.hashPrefix('');
}]);

app.run(function($rootScope,$location) {

});