var app = angular.module('ccbolApp.registroCtrl',['ngStorage']);

app.controller('registroCtrl', ['$scope','$location','registroServices','$sessionStorage',function($scope,$location,registroServices,$sessionStorage){

$scope.cityList = {nombre:["Santa Cruz de la Sierra","El Alto","La Paz","Cochabamba","Oruro","Sucre","Tarija","Potosí","Sacaba","Quillacollo","Montero","Trinidad","Riberalta","Warnes","La Guardia","Viacha","Yacuiba","Colcapirhua","Tiquipaya","Cobija","Vinto","Guayaramerín","Villazón","Villa Yapacaní","Villa Montes","Bermejo","Camiri","Tupiza","Llallagua","San Ignacio de Velasco","San Julián","Huanuni"]};
$scope.collegeList = { nombre: ["(UMSS) Universidad Mayor de San Simón","(UMSA) Universidad Mayor de San Andrés","(UCB) Universidad Católica Boliviana","(USFX) Universidad Mayor de San Francisco Xavier","(UPSA) Universidad Privada de Santa Cruz de la Sierra","(UAGRM) Universidad Autónoma Gabriel René Moreno","(UPB) Universidad Privada Boliviana","(UNIVALLE) Universidad Privada del Valle","(UDABOL) Universidad de Aquino Bolivia","(UAJMS) Universidad Autónoma Juan Misael Saracho","Universidad Nur","(UASB) Universidad Andina Simón Bolivar","(UTO) Universidad Técnica de Oruro","(UPAL) Universidad Privada Abierta Latinoamericana",   "(UATF) Universidad Autónoma Tomás Frías","(USALESIANA) Universidad Salesiana de Bolivia","(UPDS) Universidad Privada Domingo Savio","(EMI) Escuela Militar de Ingeniería","(UTEPSA) Universidad Tecnológica Privada de Santa Cruz","(UAB) Universidad Adventista de Bolivia","Universidad Loyola","(UNIFRANZ) Universidad Privada Franz Tamayo","(UNSLP) Universidad Privada Nuestra Señora de La Paz","(UNICEN) Universidad Central","(UABJB) Universidad Autónoma del Beni José Ballivián","(UTB) Universidad Tecnológica Boliviana","(UNSXX) Universidad Nacional de Siglo XX","(UEB) Universidad Evangélica Boliviana","(UPEA) Universidad Pública de El Alto",    "(UECOLOGIA) Universidad Nacional Ecológica",   "(USFA) Universidad Privada San Francisco de Asís", "(UCEBOL) Universidad Cristiana de Bolivia",    "(UAP) Universidad Amazónica de Pando", "(UNITEPC) Universidad Técnica Privada Cosmos", "(UCORDILLERA) Universidad de la Cordillera","(ULS) Universidad La Salle",   "(UREAL) Universidad Real", "(UPIEB) Universidad para la Investigación Estratégica en Bolivia",  "(UDELOSANDES) Universidad de los Andes", "(UNO) Universidad Nacional del Oriente", "Universidad Privada Cumbre", "(UCATEC) Universidad Privada de Ciencias Administrativas y Tecnológicas","(USIP) Universidad Simón I. Patiño", "(UDI) Universidad para el Desarrollo y la Innovación",  "(UB) Universidad Unión Bolivariana", "(UNIOR) Universidad Privada de Oruro",  "(UNIBETH) Universidad Bethesda", "(ULAT) Universidad Latinoamericana",    "(UBI) Universidad Boliviana de Informática", "Universidad Unidad","(USP) Universidad Saint Paul"]};
$scope.careerList = { nombre: ["Ing. de Sistemas","Ing. de Telecomunicaciones","Ing.Informática","Ing. de Software"]};


// autocompletate
$scope.completeCity = function(string){
    if(string) {
        $scope.hidethis = false;
        var output = [];
        angular.forEach($scope.cityList.nombre, function(city){ 
            if(city.toLowerCase().indexOf(string.toLowerCase()) >= 0)  {
                output.push(city);
            }
        });
        $scope.filterCity = output;
    } else
        $scope.filterCity = [];
    };
$scope.fillTextboxCity = function(string){
    $scope.studentEdit._city = string;
    $scope.hidethis = true;
};
$scope.completeCity2 = function(string){
    if(string) {
        $scope.hidethis = false;
        var output = [];
        angular.forEach($scope.cityList.nombre, function(city){ 
            if(city.toLowerCase().indexOf(string.toLowerCase()) >= 0)  {
                output.push(city);
            }
        });
        $scope.filterCity = output;
    } else
        $scope.filterCity = [];
    };
$scope.fillTextboxCity2 = function(string){
    $scope.profesionalEdit._city = string;
    $scope.hidethis = true;
};

$scope.completeCollege = function(string){
    if(string) {
        $scope.hidethisCollege = false;
        var outputC = [];
        angular.forEach($scope.collegeList.nombre, function(college){ 
            if(college.toLowerCase().indexOf(string.toLowerCase()) >= 0)  {
                outputC.push(college);
            }
        });
        $scope.filterCollege = outputC;
    }
    else
        $scope.filterCollege = [];
};
$scope.fillTextboxCollege = function(string){
    $scope.studentEdit._college = string;
    $scope.hidethisCollege = true;
};
$scope.completeCareer = function(string){
    if(string) {
        $scope.hidethisCareer = false;
        var outputCar = [];
        angular.forEach($scope.careerList.nombre, function(career){ 
            if(career.toLowerCase().indexOf(string.toLowerCase()) >= 0)  {
                outputCar.push(career);
            }
        });
        $scope.filterCareer = outputCar;
    }
    else
        $scope.filterCareer = [];
};
$scope.fillTextboxCareer = function(string){
    $scope.studentEdit._career = string;
    $scope.hidethisCareer = true;
};
// end autocompletate
$scope.loader = false;
$scope.viewStudent = false;
$scope.viewProfesional = false;
$scope.dataError = false;

$scope.callFunctionGetData = true;

/* SendData User, verifica llama a la funcion getDataUser en 500ms de leer el barcode*/
$scope.sendDataUser = function(){
    if($scope.callFunctionGetData){
        $scope.callFunctionGetData = false;
            setTimeout(function() {
                $scope.getDataUser();
              }, 500);
    }
}
/* recibe la lectura del barcode y hace la peticion a la api, devuelve la data de estudiante o profesional */
$scope.getDataUser = function(){ 
    $scope.loader = true;
        
    if(typeof($scope.barcode) == 'undefined') {
        $scope.getBarcode = "Lea Barcode primero";
    }else{
        registroServices.getUserData( $scope.barcode ).then(function(){
        $scope.loader = false;
        $scope.callFunctionGetData = true;       
        $scope.dataResponse = registroServices.response;
        console.log($scope.dataResponse);
        if($scope.dataResponse.error == 'not'){
            $scope.dataError = false;
            if($scope.dataResponse.type == '1'){
                $scope.viewStudent = true;
                $scope.viewProfesional = false;
                $scope.dataUser = $scope.dataResponse;
            }else{
                $scope.viewProfesional = true;
                $scope.viewStudent = false;
                $scope.dataUser = $scope.dataResponse;
            }
        }else{
            $scope.dataError = true;
            $scope.viewProfesional = false;
            $scope.viewStudent = false;
            console.log($scope.dataResponse);
        }
        $scope.barcode = "";
        });
    }

}
/*muestra el modal de edicion de datos de estudiante*/
$scope.showModalEditStudent =  function(student){
    $scope.studentEdit;
    $scope.studentEdit = student;
    //select cargo
        $scope.data2 = {
            model: $scope.studentEdit._cargo,
            availableOptions: [
            {name: 'PARTICIPANTE'},
            {name: 'ORGANIZADOR'},
            {name: 'EXPOSITOR'}
            ]
        };

    $('#modalStudent').modal('show')
}

$scope.editStudent = function(){
    console.log($scope.studentEdit)
}

/*muestra el modal de edicon de datos de p*/
$scope.showModalEditProfesional =  function(profesional){
    $scope.profesionalEdit = profesional;
    $('#modalProfesional').modal('show');
    //select cargo
        $scope.data = {
            model: $scope.profesionalEdit._cargo,
            availableOptions: [
            {name: 'PARTICIPANTE'},
            {name: 'ORGANIZADOR'},
            {name: 'EXPOSITOR'}
            ]
        };
    $('#modalStudent').modal('show')
}
$scope.editProfesional = function(){
    console.log($scope.profesionalEdit)
}

// editar
$scope.loaderUpdateStudent = false;

$scope.editStudentData = function(data){

     $scope.loaderUpdateStudent = true;
     data._id_admin = $sessionStorage.data.id;
     data._cargo = $scope.data2.model;
     console.log(data);
        // registroServices.updateUserData( data ).then(function(){
        // $scope.loaderUpdateStudent = false;
        // $scope.dataUpdateStudent = registroServices.response;
        // console.log($scope.dataUpdateStudent);
        //     setTimeout(function() {
        //         $('#modalStudent').modal('hide');
        //         $scope.dataUpdateStudent.respuesta = ''
        //     }, 1000);
        // });
}
$scope.loaderUpdatePro = false;
$scope.editProfesionalData = function(data){
    data._career = data._professional_degree;
    data._college = '';
    data._id_admin = $sessionStorage.data.id;
    data._cargo = $scope.data.model;
     $scope.loaderUpdatePro = true;
     console.log(data)
        // registroServices.updateUserData( data ).then(function(){
        // $scope.loaderUpdatePro = false;
        // $scope.dataUpdatePro = registroServices.response;
        // console.log($scope.dataUpdatePro);
        //     setTimeout(function() {
        //         $('#modalProfesional').modal('hide');
        //         $scope.dataUpdatePro.respuesta = ''
        //     }, 500);
        // });
}





/*PAID*/

$scope.paid = function(data){
    console.log(data._id);
}


}]) 
