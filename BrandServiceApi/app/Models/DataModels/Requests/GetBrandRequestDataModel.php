<?php
namespace App\Models\DataModels\Requests;
use App\Models\Common\DataModels\BaseDataModel;
use App\Models\Common\DataModels\ApiRequestDataModel;
use App\Models\Common\DataModels\BrandDataModel;
use App\Libraries\{ParameterException};

class GetBrandRequestDataModel extends ApiRequestDataModel
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
        if (empty($brand) || empty($brand->brandId)) {
            throw new ParameterException(MANDATORY_PARAMETER_ERROR, 'brandId');
        }
    }

    public static function fromJson($jsonString)
    {
        $jsonData = BaseDataModel::jsonDecode($jsonString);
        $getBrandRequestDataModel = new GetBrandRequestDataModel();

        if ($jsonData !== null) {
            $brand = $jsonData->brand ?? null;
            if ($brand !== null) {
                $brandDataModel = BrandDataModel::fromJson($brand);
                $getBrandRequestDataModel->brand = $brandDataModel;
            }
        }

        return $getBrandRequestDataModel;
    }
}