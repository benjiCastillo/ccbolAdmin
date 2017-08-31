var app = angular.module('ccbolApp',
	['ngRoute',
    'jcs-autoValidate',
    'ccbolApp.homeCtrl',
    'ccbolApp.registroCtrl',
    'ccbolApp.preinscripcionCtrl',
    'ccbolApp.registroServices'
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
    /* Hammer js para el swip */
    var menu = $('#main-container')[0];

     $scope.closeMenu = function(){
            $('#menu-xs-sm').css("left", "-200px");
            $('#menu-xs-sm').attr("data-active","false");
     }   

     var head = document.getElementsByTagName('head')[0];

        // Save the original method
        var insertBefore = head.insertBefore;

        // Replace it!
        head.insertBefore = function (newElement, referenceElement) {

            if (newElement.href && newElement.href.indexOf('//fonts.googleapis.com/css?family=Roboto') > -1) {

                // console.info('Prevented Roboto from loading!');
                return;
            }

            insertBefore.call(head, newElement, referenceElement);
        };

}]);

 app.config( function ($routeProvider) {

	$routeProvider
	.when('/', {
		templateUrl: 'assets/js/angular/pages/home.html',
        controller: 'homeCtrl'
	})
	.when('/ccbol', {
		templateUrl: 'assets/js/angular/pages/home.html',
        controller: 'homeCtrl'
    })
    .when('/registro', {
		templateUrl: 'assets/js/angular/pages/registro.html',
        controller: 'registroCtrl'
    })
	.when('/pre-inscripcion', {
		templateUrl: 'assets/js/angular/pages/preinscripcion.html',
        controller: 'preinscripcionCtrl'
	})             
	.otherwise({ 
		redirectTo: '/', 
	});
});

app.config(['$locationProvider', function($locationProvider) {
  $locationProvider.hashPrefix('');
}]);

app.run(function($rootScope,$location) {
    var routespermission = ['/ccbol'];
    $rootScope.$on('$routeChangeStart',function() {
        if( !(routespermission.indexOf($location.path()) != -1) ) {
            if( typeof timerId != 'undefined' )
                window.clearInterval(timerId);
            //console.log('Otros enlaces');
        } 
    });
});