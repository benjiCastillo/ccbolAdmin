var app = angular.module('ccbolApp.registroCtrl',['ngStorage']);

app.controller('registroCtrl', ['$scope','$location','registroServices','$sessionStorage','$rootScope',function($scope,$location,registroServices,$sessionStorage,$rootScope){


/*location segurity*/

$scope.verButton = false;

    $scope.generar = function(data,frmUser) {
            $scope.loader = true;
            registroServices.ciBarcode( data._ci ).then(function(){
                console.log(registroServices.response)
                $scope.dataResponse = registroServices.response;
                $scope.loader = false;
                if($scope.dataResponse.error == 'not'){
                       console.log($scope.dataResponse) 
                       $scope.verButton = true;
                       $rootScope.rName =  $scope.dataResponse.name;
                       $rootScope.rLastName = $scope.dataResponse.last_name;
                       $rootScope.rId = $scope.dataResponse.id;
                }else{
                    console.log($scope.dataResponse.message)
                    $scope.verButton = false;
                }

                // frmUser.autoValidateFormOptions.resetForm();

                });
    
            };
$scope.auth = function(){
    $scope.successAccess = false;
    if($location.path() == '/registro'){
        if(typeof($sessionStorage.data.id) != 'undefined'){
             $scope.successAccess = true;
             console.log("correcto");
        }else{
            console.log('no deberias estar aqui');
             $scope.successAccess = false;
        }
    }
}

$scope.auth();

/* LogOut */
$scope.logOut = function(){
    registroServices.logOut($sessionStorage.data.id ).then(function(){
        $scope.dataLogOut = registroServices.response;
        console.log($scope.dataLogOut);
        $sessionStorage.data = "";
        $location.path('/home');
    });
}

}]) 