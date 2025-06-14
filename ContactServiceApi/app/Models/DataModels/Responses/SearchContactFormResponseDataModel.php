<?php
namespace App\Models\DataModels\Responses;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\PaginationResponseDataModel;
use App\Models\Common\DataModels\PaginationDataModel;
use App\Models\Common\DataModels\ContactFormDataModel;

class SearchContactFormResponseDataModel extends PaginationResponseDataModel
{

    public $contactForms;
	public function __construct()
	{
		parent::__construct();
	}

    public function validateAndEnrichData()
	{
		//Validate mandatory inputs

		//Optional inputs and setting defaults			

	}

    public static function fromJson($jsonString)
	{
		$jsonData = BaseDataModel::jsonDecode($jsonString);
		$searchContactFormResponseDataModel = new SearchContactFormResponseDataModel();
		if ($jsonData != null) {

            $contactForms = $jsonData->contactForms ?? null;
			if ($contactForms != null) {
				$searchContactFormResponseDataModel->contactForms = array();
				foreach ($contactForms as $contactForm) {
					$contactFormDataModel = ContactFormDataModel::fromJson($contactForm);
					$searchContactFormResponseDataModel->contactForms[] = $contactFormDataModel;
				}
			}
		
			
            $pagination = $jsonData->pagination ?? null;
			if ($pagination != null) {
				$paginationDataModel = PaginationDataModel::fromJson($pagination);
				$searchContactFormResponseDataModel->pagination = $paginationDataModel;
			}
		}
		return $searchContactFormResponseDataModel;
	}

}