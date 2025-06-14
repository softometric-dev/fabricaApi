<?php
namespace App\Models\DataModels\Responses;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiResponseDataModel;
use App\Models\Common\DataModels\ContactFormDataModel;

class DeleteContactFormResponseDataModel extends ApiResponseDataModel
{
    public $deletedContactForm;
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
		$deleteContactFormResponseDataModel = new DeleteContactFormResponseDataModel();
		if ($jsonData != null) {
			$deletedContactForm = $jsonData->deletedContactForm ?? null;
			if ($deletedContactForm != null) {
				$contactFormDataModel = ContactFormDataModel::fromJson($deletedContactForm);
				$deleteContactFormResponseDataModel->deletedContactForm = $contactFormDataModel;
			}
		}
		return $deleteContactFormResponseDataModel;
	}
}