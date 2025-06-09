<?php
namespace App\Models\DataModels\Requests;
use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiRequestDataModel;
use App\Models\Common\DataModels\BrandDataModel;
use App\Libraries\{ParameterException};

class UpdateBrandRequestDataModel extends ApiRequestDataModel
{
    public $brand;

    public function __construct()
    {
        parent::__construct();
    }

    public function validateAndEnrichData()
    {
        $brand = $this->brand;

        // Validate mandatory inputs
        if (empty($brand) || empty($brand->brandId) || empty($brand->brandModifiedDateTime)) {
            throw new ParameterException(MANDATORY_PARAMETER_ERROR, 'brandId, brandModifiedDateTime');
        }

        // Optional inputs and setting defaults
    }

    public static function fromJson($jsonString)
    {
        $jsonData = BaseDataModel::jsonDecode($jsonString);
        $updateBrandRequestDataModel = new UpdateBrandRequestDataModel();

      
        if ($jsonData !== null) {
            $brand = $jsonData->brand ?? null;

            if ($brand !== null) {
         
                $brandDataModel = BrandDataModel::fromJson($brand);

                $updateBrandRequestDataModel->brand = $brandDataModel;
            }
        }

        return $updateBrandRequestDataModel;
    }
}