var app = angular.module('ccbolApp.homeCtrl',['ngStorage']);

app.controller('homeCtrl', ['$scope','$location','registroServices','$sessionStorage',function($scope,$location,registroServices,$sessionStorage){
    //animations
    setTimeout(function(){
        $('.img-port-slide').addClass('animated visible flipInX');
    },0);
    setTimeout(function(){
        $('.titulo-ccbol').addClass('animated visible fadeInDown');
    },600);
    setTimeout(function(){
        $('.sub-titulo').addClass('animated visible slideInUp');
    },1200);
    setTimeout(function(){
        $('.timer-container').addClass('animated visible bounceInUp');
    },1500);


    $scope.loader = false;
    $sessionStorage.data = {};

    $scope.guardar = function(data,frmUser) {
        $scope.loader = true;
        registroServices.guardarEst( data ).then(function(){
        $scope.loader = false;
        $scope.dataResponse = registroServices.response;
        // console.log($scope.dataResponse);
            if($scope.dataResponse.error == 'not'){
                $location.path('/registro-exitoso');
                frmUser.autoValidateFormOptions.resetForm();
            }
        });
        
    };
    /*LOGIN ADMIN*/
    $scope.logInAdmin = function(data){
    
        registroServices.guardarEst( data ).then(function(){
        $scope.loader = false;
        $scope.dataResponse = registroServices.response;
        console.log($scope.dataResponse);
        // console.log($scope.dataResponse);
            if($scope.dataResponse.error == 'not'){
                console.log($scope.dataResponse);
                $sessionStorage.data.id = $scope.dataResponse.id;
                $location.path('/registro');
            }
        });
    } 

    /*loaction segurity*/

    $scope.auth = function(){
        $scope.successAccess = false;
        if($location.path() == '/'){
            $sessionStorage.data.id = undefined;
        }
    }

    $scope.auth();

}]) 
