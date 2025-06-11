<?php
namespace App\Models\DataModels\Requests;
use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiRequestDataModel;
use App\Models\Common\DataModels\ProductDataModel;
use App\Libraries\{ParameterException};


class DeleteProductRequestDataModel extends ApiRequestDataModel
{
    public $productToDelete;
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
		$deleteProductRequestDataModel = new DeleteProductRequestDataModel();
		if ($jsonData != null) {
			$productToDelete = $jsonData->productToDelete ?? null;
			if ($productToDelete != null) {
				$productDataModel = ProductDataModel::fromJson($productToDelete);
				$deleteProductRequestDataModel->productToDelete = $productDataModel;
			}
		}
		return $deleteProductRequestDataModel;
	}
}