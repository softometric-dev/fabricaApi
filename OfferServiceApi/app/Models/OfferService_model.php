<?php

namespace App\Models;
use App\Libraries\CustomExceptionHandler;
use App\Models\Common\Base_model;
use App\Models\Common\DataModels\PaginationDataModel;
use App\Models\Common\DataModels\OfferDataModel;
use CodeIgniter\Database\Exceptions\DatabaseException;

class OfferService_model extends Base_model
{
    public function __construct()
    {	
        parent::__construct();	
    } 

    function createOfferProc($createOfferRequestDataModel,&$createOfferResponseDataModel)
	{
        
        
        $newOffer = $createOfferRequestDataModel->newOffer;
      
        $sql = "CALL sp_createOffer(?,?,?,?,?)";
       
        try {
            $query1 = $this->db->query($sql, [
                $newOffer->offerName,
                $newOffer->title,
                $newOffer->date,
                $newOffer->description,
                $newOffer->image,
            ]);
        } catch (DatabaseException $e) {
            $this->checkDBError();
        }

       
        $resultSet1 = OfferDataModel::fromDbResultSet($query1->getResultArray());
      
        $createOfferResponseDataModel->newOffer = count($resultSet1) > 0 ? $resultSet1[0] : null;
    }

    function getOfferProc($getOfferRequestDataModel, &$getOfferResponseDataModel)
    { 
        
        $offer = $getOfferRequestDataModel->offer;

        $sql = "CALL sp_getOfferByOfferId(?)";
        try {
         $query = $this->db->query($sql, [$offer->offerId]);
        } catch (DatabaseException $e) {
            $this->checkDBError();
        }

        
         $resultSet1 = OfferDataModel::fromDbResultSet($query->getResultArray());
         $getOfferResponseDataModel->offer = count($resultSet1) > 0 ? $resultSet1[0] : null;
       
    }

    function getOfferByIdProc($offerId)
    { 
        
        $sql = "CALL sp_getOfferByOfferId(?)";
        try {
         $query = $this->db->query($sql, [$offerId]);
        } catch (DatabaseException $e) {
            $this->checkDBError();
        }

        
         // Fetch the result as an array of objects or arrays
         $resultSet1 = OfferDataModel::fromDbResultSet($query->getResultArray());
         $offer = count($resultSet1) > 0 ? $resultSet1[0] : null;
         return $offer;
    }


    function updatOfferProc($updateOfferRequestDataModel, &$updateOfferResponseDataModel)
    {
        

        $offer = $updateOfferRequestDataModel->offer;
       
        $sql1 = "CALL sp_updateOffer(?,?,?,?,?,?,?)";
        try {
            $query1 = $this->db->query($sql1, [
                $offer->offerId,
                 $offer->offerName,
                 $offer->title,
                 $offer->date,
                 $offer->description,
                 $offer->image,
                 $offer->offerModifiedDateTime,
               
            ]);
        } catch (DatabaseException $e) {
            $this->checkDBError();
        }

        // Free the result object
        $this->db->connID->next_result();
        $query1->freeResult();

          // Step 2: Get updated loyalty program details
          $sql2 = "CALL sp_getOfferByOfferId(?)";
          try {
            $query2 = $this->db->query($sql2, [
             $offer->offerId,
            ]);
        } catch (DatabaseException $e) {
            $this->checkDBError();
        }
         

         $resultSet1 = OfferDataModel::fromDbResultSet($query2->getResultArray());
       
         $updateOfferResponseDataModel->offer = count($resultSet1) > 0 ? $resultSet1[0] : null;

    }

     function deleteOfferProc($deleteOfferRequestDataModel, &$deleteOfferResponseDataModel)
    {
        
        $offerToDelete = $deleteOfferRequestDataModel->offerToDelete;

        $sql = "CALL sp_deleteOfferById(?)";
        try {
            $query = $this->db->query($sql, [
                $offerToDelete->offerId
            ]);
        } catch (DatabaseException $e) {
            $this->checkDBError();
        }
            
        $resultSet = OfferDataModel::fromDbResultSet($query->getResultArray());
		$deleteOfferResponseDataModel->deletedOffer = count($resultSet) > 0 ? $resultSet[0] : null;
        
    }

     function searchOfferProc($searchOfferRequestDataModel, &$searchOfferResponseDataModel)
    {
        
        $offer = $searchOfferRequestDataModel->offer;
        $pagination = $searchOfferRequestDataModel->pagination;
      
        $sql = "CALL sp_searchOffer(?,?,?,?)";
        try {
            $query = $this->db->query($sql, [
                $offer->offerName,
                $offer->title,
                $pagination->currentPage,
                $pagination->pageSize,
            ]);

        } catch (DatabaseException $e) {
            $this->checkDBError();
        }


        $resultSet1 = $query->getResultArray();
        
        $searchOfferResponseDataModel->offers = !empty($resultSet1) ? OfferDataModel::fromDbResultSet($resultSet1) : null;

        // Move to the next result set
        $this->db->connID->next_result();

        $nextResultSet = $this->db->connID->store_result();
        // $resultSet2 = $nextResultSet->fetch_all(MYSQLI_ASSOC);

        $resultSet2 = PaginationDataModel::fromDbResultSet($nextResultSet->fetch_all(MYSQLI_ASSOC));
        $searchOfferResponseDataModel->pagination = count($resultSet2) > 0 ? $resultSet2[0] : null;
        
    }

}