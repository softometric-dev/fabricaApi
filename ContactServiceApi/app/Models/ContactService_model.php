<?php

namespace App\Models;
use App\Libraries\CustomExceptionHandler;
use App\Models\Common\Base_model;
use App\Models\Common\DataModels\PaginationDataModel;
use App\Models\Common\DataModels\ContactFormDataModel;
use App\Models\Common\DataModels\DealEnquiryDataModel;
use App\Models\Common\DataModels\PartnerDataModel;
use App\Models\Common\DataModels\ProductEnquiryDataModel;
use CodeIgniter\Database\Exceptions\DatabaseException;

class ContactService_model extends Base_model
{
    public function __construct()
    {	
        parent::__construct();	
    } 

    function createProductEnquiryProc($createProductEnquiryRequestDataModel,&$createProductEnquiryResponseDataModel)
	{
        
        $newProductEnquiry = $createProductEnquiryRequestDataModel->newProductEnquiry;
      
        $sql = "CALL sp_createProductEnquiry(?,?,?)";
       
        try {
            $query1 = $this->db->query($sql, [
                $newProductEnquiry->fullName,
                $newProductEnquiry->companyName,
                $newProductEnquiry->email,
            ]);
        } catch (DatabaseException $e) {
            $this->checkDBError();
        }

       
        $resultSet1 = ProductEnquiryDataModel::fromDbResultSet($query1->getResultArray());
      
        $createProductEnquiryResponseDataModel->newProductEnquiry = count($resultSet1) > 0 ? $resultSet1[0] : null;
    }

    function createDealEnquiryProc($createDealEnquiryRequestDataModel,&$createDealEnquiryResponseDataModel)
	{
        
        $newDealEnquiry = $createDealEnquiryRequestDataModel->newDealEnquiry;
      
        $sql = "CALL sp_createDealEnquiry(?,?,?)";
       
        try {
            $query1 = $this->db->query($sql, [
                $newDealEnquiry->fullName,
                $newDealEnquiry->companyName,
                $newDealEnquiry->email,
            ]);
        } catch (DatabaseException $e) {
            $this->checkDBError();
        }

       
        $resultSet1 = DealEnquiryDataModel::fromDbResultSet($query1->getResultArray());
      
        $createDealEnquiryResponseDataModel->newDealEnquiry = count($resultSet1) > 0 ? $resultSet1[0] : null;
    }

    function createPartnerProc($createPartnerRequestDataModel,&$createPartnerResponseDataModel)
	{
        
        $newPartner = $createPartnerRequestDataModel->newPartner;
      
        $sql = "CALL sp_createPartner(?,?,?,?)";
       
        try {
            $query1 = $this->db->query($sql, [
                $newPartner->fullName,
                $newPartner->companyName,
                $newPartner->email,
                $newPartner->comment,
            ]);
        } catch (DatabaseException $e) {
            $this->checkDBError();
        }

       
        $resultSet1 = PartnerDataModel::fromDbResultSet($query1->getResultArray());
      
        $createPartnerResponseDataModel->newPartner = count($resultSet1) > 0 ? $resultSet1[0] : null;
    }

    function createContactFormProc($createContactFormRequestDataModel,&$createContactFormResponseDataModel)
	{
        
        $newContactForm = $createContactFormRequestDataModel->newContactForm;
      
        $sql = "CALL sp_createContactForm(?,?,?,?,?)";
       
        try {
            $query1 = $this->db->query($sql, [
                $newContactForm->fullName,
                $newContactForm->phone,
                $newContactForm->email,
                $newContactForm->subject,
                $newContactForm->comment,
            ]);
        } catch (DatabaseException $e) {
            $this->checkDBError();
        }

       
        $resultSet1 = ContactFormDataModel::fromDbResultSet($query1->getResultArray());
      
        $createContactFormResponseDataModel->newContactForm = count($resultSet1) > 0 ? $resultSet1[0] : null;
    }

    function searchProductEnquiryProc($searchProductEnquiryRequestDataModel, &$searchProductEnquiryResponseDataModel)
    {
        
        $productEnquiry = $searchProductEnquiryRequestDataModel->productEnquiry;
        $pagination = $searchProductEnquiryRequestDataModel->pagination;
      
        $sql = "CALL sp_searchProductEnquiry(?,?,?,?,?)";
        try {
            $query = $this->db->query($sql, [
                $productEnquiry->fullName,
                $productEnquiry->companyName,
                $productEnquiry->email,
                $pagination->currentPage,
                $pagination->pageSize,
            ]);

        } catch (DatabaseException $e) {
            $this->checkDBError();
        }

        $resultSet1 = $query->getResultArray();
        
        $searchProductEnquiryResponseDataModel->productEnquiries = !empty($resultSet1) ? ProductEnquiryDataModel::fromDbResultSet($resultSet1) : null;

        // Move to the next result set
        $this->db->connID->next_result();

        $nextResultSet = $this->db->connID->store_result();

        $resultSet2 = PaginationDataModel::fromDbResultSet($nextResultSet->fetch_all(MYSQLI_ASSOC));
        $searchProductEnquiryResponseDataModel->pagination = count($resultSet2) > 0 ? $resultSet2[0] : null;
        
    }

      function searchDealEnquiryProc($searchDealEnquiryRequestDataModel, &$searchDealEnquiryResponseDataModel)
    {
        
        $dealEnquiry = $searchDealEnquiryRequestDataModel->dealEnquiry;
        $pagination = $searchDealEnquiryRequestDataModel->pagination;
      
        $sql = "CALL sp_searchDealEnquiry(?,?,?,?,?)";
        try {
            $query = $this->db->query($sql, [
                $dealEnquiry->fullName,
                $dealEnquiry->companyName,
                $dealEnquiry->email,
                $pagination->currentPage,
                $pagination->pageSize,
            ]);

        } catch (DatabaseException $e) {
            $this->checkDBError();
        }

        $resultSet1 = $query->getResultArray();
        
        $searchDealEnquiryResponseDataModel->dealEnquiries = !empty($resultSet1) ? DealEnquiryDataModel::fromDbResultSet($resultSet1) : null;

        // Move to the next result set
        $this->db->connID->next_result();

        $nextResultSet = $this->db->connID->store_result();

        $resultSet2 = PaginationDataModel::fromDbResultSet($nextResultSet->fetch_all(MYSQLI_ASSOC));
        $searchDealEnquiryResponseDataModel->pagination = count($resultSet2) > 0 ? $resultSet2[0] : null;
        
    }

    function searchPartnerProc($searchPartnerRequestDataModel, &$searchPartnerResponseDataModel)
    {
        
        $partner = $searchPartnerRequestDataModel->partner;
        $pagination = $searchPartnerRequestDataModel->pagination;
      
        $sql = "CALL sp_searchPartner(?,?,?,?,?)";
        try {
            $query = $this->db->query($sql, [
                $partner->fullName,
                $partner->companyName,
                $partner->email,
                $pagination->currentPage,
                $pagination->pageSize,
            ]);

        } catch (DatabaseException $e) {
            $this->checkDBError();
        }

        $resultSet1 = $query->getResultArray();
        
        $searchPartnerResponseDataModel->partners = !empty($resultSet1) ? PartnerDataModel::fromDbResultSet($resultSet1) : null;

        // Move to the next result set
        $this->db->connID->next_result();

        $nextResultSet = $this->db->connID->store_result();

        $resultSet2 = PaginationDataModel::fromDbResultSet($nextResultSet->fetch_all(MYSQLI_ASSOC));
        $searchPartnerResponseDataModel->pagination = count($resultSet2) > 0 ? $resultSet2[0] : null;
        
    }

     function searchContactFormProc($searchContactFormRequestDataModel, &$searchContactFormResponseDataModel)
    {
        
        $contactForm = $searchContactFormRequestDataModel->contactForm;
        $pagination = $searchContactFormRequestDataModel->pagination;
      
        $sql = "CALL sp_searchContactForm(?,?,?,?,?,?)";
        try {
            $query = $this->db->query($sql, [
                $contactForm->fullName,
                $contactForm->phone,
                $contactForm->email,
                $contactForm->subject,
                $pagination->currentPage,
                $pagination->pageSize,
            ]);

        } catch (DatabaseException $e) {
            $this->checkDBError();
        }

        $resultSet1 = $query->getResultArray();
        
        $searchContactFormResponseDataModel->contactForms = !empty($resultSet1) ? ContactFormDataModel::fromDbResultSet($resultSet1) : null;

        // Move to the next result set
        $this->db->connID->next_result();

        $nextResultSet = $this->db->connID->store_result();

        $resultSet2 = PaginationDataModel::fromDbResultSet($nextResultSet->fetch_all(MYSQLI_ASSOC));
        $searchContactFormResponseDataModel->pagination = count($resultSet2) > 0 ? $resultSet2[0] : null;
        
    }

    function deleteProductEnquiryProc($deleteProductEnquiryRequestDataModel, &$deleteProductEnquiryResponseDataModel)
    {
        
        $productEnquiryToDelete = $deleteProductEnquiryRequestDataModel->productEnquiryToDelete;

        $sql = "CALL sp_deleteProductEnquiryById(?)";
        try {
            $query = $this->db->query($sql, [
                $productEnquiryToDelete->productEnquiryId
            ]);
        } catch (DatabaseException $e) {
            $this->checkDBError();
        }
            
        $resultSet = ProductEnquiryDataModel::fromDbResultSet($query->getResultArray());
		$deleteProductEnquiryResponseDataModel->deletedProductEnquiry = count($resultSet) > 0 ? $resultSet[0] : null;
        
    }

    function deleteDealEnquiryProc($deleteDealEnquiryRequestDataModel, &$deleteDealEnquiryResponseDataModel)
    {
        
        $dealEnquiryToDelete = $deleteDealEnquiryRequestDataModel->dealEnquiryToDelete;

        $sql = "CALL sp_deleteDealEnquiry(?)";
        try {
            $query = $this->db->query($sql, [
                $dealEnquiryToDelete->dealEnquiryId
            ]);
        } catch (DatabaseException $e) {
            $this->checkDBError();
        }
            
        $resultSet = DealEnquiryDataModel::fromDbResultSet($query->getResultArray());
		$deleteDealEnquiryResponseDataModel->deletedDealEnquiry = count($resultSet) > 0 ? $resultSet[0] : null;
        
    }

    function deletePartnerProc($deletePartnerRequestDataModel, &$deletePartnerResponseDataModel)
    {
        
        $partnerToDelete = $deletePartnerRequestDataModel->partnerToDelete;

        $sql = "CALL sp_deletePartner(?)";
        try {
            $query = $this->db->query($sql, [
                $partnerToDelete->partnerId
            ]);
        } catch (DatabaseException $e) {
            $this->checkDBError();
        }
            
        $resultSet = PartnerDataModel::fromDbResultSet($query->getResultArray());
		$deletePartnerResponseDataModel->deletedDealEnquiry = count($resultSet) > 0 ? $resultSet[0] : null;
        
    }

    function deleteContactFormProc($deleteContactFormRequestDataModel, &$deleteContactFormResponseDataModel)
    {
        
        $contactFormToDelete = $deleteContactFormRequestDataModel->contactFormToDelete;

        $sql = "CALL sp_deleteContactForm(?)";
        try {
            $query = $this->db->query($sql, [
                $contactFormToDelete->contactId
            ]);
        } catch (DatabaseException $e) {
            $this->checkDBError();
        }
            
        $resultSet = ContactFormDataModel::fromDbResultSet($query->getResultArray());
		$deleteContactFormResponseDataModel->deletedContactForm = count($resultSet) > 0 ? $resultSet[0] : null;
        
    }

}