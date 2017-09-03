<?php 

namespace App\Model;

use App\Lib\Response,
	App\Lib\Security;

/**
* Modelo usuario
*/
class  EventModel
{
	private $db;
	private $table = 'event';
	private $response;



	public function __CONSTRUCT($mysqli){
		$this->mysqli   = $mysqli;
		$this->response = new Response();
		$this->security = new Security();
	}

	//var $l => 'limit', $p => 'pagina'

	//lista_total
	public function listar(){

		return $data = $this->db->from($this->table)
						 ->orderBy('id DESC')
						 ->fetchAll();
	//  return $data = $this->mysqli->query('select * from '.$this->table)
	//					 			->fetchAll();				   						 
	}

	//listar paginado
	//parametros de limite, pagina
	public function paginated($l, $p){	
		$p = $p*$l;
		$data = $this->db->from($this->table)
						 ->limit($l)
						 ->offset($p)
						 ->orderBy('id desc')
						 ->fetchAll();

		$total = $this->db->from($this->table)
						  ->select('COUNT(*) Total')
						  ->fetch()
						  ->Total;

		return [
			'data'	=>   $data,
			'total' =>   $total

		];				  						 
	}
	//obtener
	public function getExamen($id){

		return $data = $this->db->from($this->table, $id)
								->fetch();  						 
	}
	public function listEvent(){

		$this->mysqli->multi_query(" CALL listEvent()");
			$res = $this->mysqli->store_result();
			while($fila = $res->fetch_assoc()){
				$arreglo[] = $fila;
			}
			$res = $arreglo;
			mysqli_close($this->mysqli);
			if($res[0]["error"] == "yes"){
				$res = array("respuesta"=>$res[0]["respuesta"], "error"=>$res[0]["error"]);
			}else{
				$res = array("message"=>$res, "error"=>"not", "response"=>true);
			}
			return $res;
			// $res = array("message"=>$res, "response"=>true);
			// return $res;		
	}

	
	//actualizar
	public function update($data, $id){

		$this->db->update($this->table, $data, $id)	
				 ->execute();

		return $this->response->setResponse(true);		 
	}
	//eliminar
	public function delete($id){

		$this->db->deleteFrom($this->table, $id)	
				 ->execute();

		return $this->response->setResponse(true);		 
	}


}


 ?>