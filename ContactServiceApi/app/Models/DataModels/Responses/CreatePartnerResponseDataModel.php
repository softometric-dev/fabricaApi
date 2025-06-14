<?php
namespace App\Models\DataModels\Responses;

use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiResponseDataModel;
use App\Models\Common\DataModels\PartnerDataModel;

class CreatePartnerResponseDataModel extends ApiResponseDataModel
{
    public $newPartner;

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
		$createPartnerResponseDataModel = new CreatePartnerResponseDataModel();
		if ($jsonData != null) {
			$newPartner = $jsonData->newPartner ?? null;
			if ($newPartner != null) {
				$partnerDataModel = PartnerDataModel::fromJson($newPartner);
				$createPartnerResponseDataModel->newPartner = $partnerDataModel;
			}



		}
		return $createPartnerResponseDataModel;
	}

}