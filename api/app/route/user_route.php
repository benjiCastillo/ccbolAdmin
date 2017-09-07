<?php 
use App\Lib\Response;

	$app->add(function ($req, $res, $next) {
    $response = $next($req, $res);
    return $response
            ->withHeader('Access-Control-Allow-Origin', 'http://localhost')
            ->withHeader('Access-Control-Allow-Headers', 'X-Requested-With, Content-Type, Accept, Origin, Authorization')
            ->withHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
});

$app->group('/user',function(){

	$this->post('/login',function($req, $res, $args){
		return $res->withHeader('Content-type', 'aplication/json')
				   ->write(
				   		json_encode($this->model->User->login($req->getParsedBody()))
				   	);
	});

	$this->get('/listStudents/',function($req, $res, $args){
		return $res->withHeader('Content-type', 'aplication/json')
				   ->write(
				   		json_encode($this->model->User->listStudents())
				   		
				   	);
	});

	$this->get('/printChecked/{id}',function($req, $res, $args){
		return $res->withHeader('Content-type', 'aplication/json')
				   ->write(
				   		json_encode($this->model->User->printChecked($args['id']))
				   		
				   	);
	});

	$this->get('/listProfessionals/',function($req, $res, $args){
		return $res->withHeader('Content-type', 'aplication/json')
				   ->write(
				   		json_encode($this->model->User->listProfessionals())
				   		
				   	);
	});

	
	$this->post('/userPaidBc/',function($req, $res, $args){
		
				return $res->withHeader('Content-type', 'aplication/json')
						   -> write(
								json_encode($this->model->User->userPaidBc($req->getParsedBody()))
		
							   );
			});

	$this->post('/printUsers/',function($req, $res, $args){
				
				return $res->withHeader('Content-type', 'aplication/json')
						   -> write(
								json_encode($this->model->User->printUsers($req->getParsedBody()))
				
							   );
			});

	$this->post('/printCount/',function($req, $res, $args){
		
				return $res->withHeader('Content-type', 'aplication/json')
						   -> write(
								json_encode($this->model->User->printCount($req->getParsedBody()))
		
							   );
			});

	$this->post('/printUpdate/',function($req, $res, $args){
				
				return $res->withHeader('Content-type', 'aplication/json')
							-> write(
								json_encode($this->model->User->printUpdate($req->getParsedBody()))
				
								);
					});

	$this->get('/logout/{id}',function($req, $res, $args){
		return $res->withHeader('Content-type', 'aplication/json')
				   ->write(
				   		json_encode($this->model->User->logout($args['id']))
				   		
				   	);
	});

	// $this->get('/userPaidCi/{id}',function($req, $res, $args){
	// 	return $res->withHeader('Content-type', 'aplication/json')
	// 			   ->write(
	// 			   		json_encode($this->model->User->userPaidCi($args['id']))
				   		
	// 			   	);
	// });

	$this->post('/userPaidCi/',function($req, $res, $args){
		
				return $res->withHeader('Content-type', 'aplication/json')
						   -> write(
								json_encode($this->model->User->userPaidCi($req->getParsedBody()))
		
							   );
			});

	$this->post('/adminLogin/',function($req, $res, $args){			
				return $res->withHeader('Content-type', 'aplication/json')
							-> write(
								json_encode($this->model->User->adminLogin($req->getParsedBody()))
				
								);
			});

	$this->get('/listUserBc/{id}',function($req, $res, $args){
		return $res->withHeader('Content-type', 'aplication/json')
				   ->write(
				   		json_encode($this->model->User->listUserBc($args['id']))
				   		
				   	);
	});

	// $this->get('/listUserCi/{id}',function($req, $res, $args){
	// 	return $res->withHeader('Content-type', 'aplication/json')
	// 			   ->write(
	// 			   		json_encode($this->model->User->listUserCi($args['id']))
				   		
	// 			   	);
	// });

	$this->post('/listUserCi/',function($req, $res, $args){
		
				return $res->withHeader('Content-type', 'aplication/json')
						   -> write(
								json_encode($this->model->User->listUserCi($req->getParsedBody()))
		
							   );
			});

	$this->post('/',function($req, $res, $args){

		return $res->withHeader('Content-type', 'aplication/json')
			       -> write(
						json_encode($this->model->User->insert($req->getParsedBody()))

				   	);
	});

	$this->post('/insertStudent/',function($req, $res, $args){

		return $res->withHeader('Content-type', 'aplication/json')
			       -> write(
						json_encode($this->model->User->insertStudent($req->getParsedBody()))

				   	);
	});

	$this->get('/countUser/',function($req, $res, $args){

		return $res->withHeader('Content-type', 'aplication/json')
			       -> write(
						json_encode($this->model->User->countUser())

				   	);
	});
	$this->post('/insertProfessional/',function($req, $res, $args){

		return $res->withHeader('Content-type', 'aplication/json')
			       -> write(
						json_encode($this->model->User->insertProfessional($req->getParsedBody()))

				   	);
	});

	$this->post('/updateUser/',function($req, $res, $args){
		
		return $res->withHeader('Content-type', 'aplication/json')
					-> write(
						json_encode($this->model->User->updateUser($req->getParsedBody()))
		
						);
			});
	
	$this->put('/{id}',function($req, $res, $args){

		return $res->withHeader('Content-type', 'aplication/json')
				   ->write(
				   		json_encode($this->model->User->update($req->getParsedBody(), $args['id'] ))
				   		
				   	);
	});

	$this->delete('/{id}',function($req, $res, $args){
		return $res->withHeader('Content-type', 'aplication/json')
				   ->write(
				   		json_encode($this->model->User->delete($args['id']))
				   		
				   	);

	});
});	
// })->add(new AuthMiddleware($app)); //agregar middleware

 ?>