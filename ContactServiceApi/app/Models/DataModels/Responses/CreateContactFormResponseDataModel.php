<?php
namespace App\Models\DataModels\Responses;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiResponseDataModel;
use App\Models\Common\DataModels\ContactFormDataModel;

class CreateContactFormResponseDataModel extends ApiResponseDataModel
{
    public $newContactForm;

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
		$createContactFormResponseDataModel = new CreateContactFormResponseDataModel();
		if ($jsonData != null) {
			$newContactForm = $jsonData->newContactForm ?? null;
			if ($newContactForm != null) {
				$contactFormDataModel = ContactFormDataModel::fromJson($newContactForm);
				$createContactFormResponseDataModel->newContactForm = $contactFormDataModel;
			}

		}
		return $createContactFormResponseDataModel;
	}

}