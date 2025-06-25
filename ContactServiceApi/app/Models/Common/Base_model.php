<?php

namespace App\Models\Common;

use CodeIgniter\Model;
use Config\Services;
use App\Libraries\DatabaseException as Cust_DatabaseException;
// use App\Exceptions\DatabaseException;
use CodeIgniter\Database\Exceptions\DatabaseException;
class Base_model extends Model
{
    // Properties
    protected $DBGroup = 'default'; // Adjust if you're using multiple database groups
    protected $table;
    protected $primaryKey;
    protected $returnType = 'array'; // or 'object'
    protected $useSoftDeletes = false;
    
    protected $baseUrl; // Adding the $baseUrl property

    // Constructor
    public function __construct()
    {
        
        parent::__construct();
        $this->db = \Config\Database::connect($this->DBGroup);
  
        // Initialize $baseUrl property if needed
        $this->baseUrl = base_url(); // or set it to a specific value
    }

    protected function checkDBError()
    {
      
        $error = $this->db->error();

        if ($error['code'] != 0) 
        {
            $errorCode = $error['code'];
            $errorMessage = $error['message'];

            if ($errorCode == 1062) 
            {
                throw new Cust_DatabaseException(DB_DUPLICATE_RECORD, 'DB Error code - ' . $errorCode . ' : ' . $errorMessage);
            } 
            else 
            {
                throw new Cust_DatabaseException(DB_ERROR, $errorCode . ' : ' . $errorMessage);
            }
        }
    }

    protected function sendGenericFormEmail(array $formData, string $formType = 'Form Submission')
    {
        $email = Services::email();

        // Fallback values to avoid "undefined index"
        $name    = $formData['fullName'] ?? 'Unknown';
        $emailId = $formData['email'] ?? 'no-reply@example.com';
        $phone   = $formData['phone'] ?? 'N/A';
        $subject = $formData['subject'] ?? 'No Subject';
        $messageContent = $formData['comment'] ?? 'No message';

        // Set sender (your system email) and reply-to (user's email if available)
        $email->setFrom('your@gmail.com', esc($name));
        $email->setTo('syed@fabricadistribution.com'); // <-- Change to your admin inbox

        if (!empty($emailId)) {
            $email->setReplyTo($emailId, $name);
        }

        // Subject line can vary by form type
        $email->setSubject("New {$formType} from {$name}");

        // Build the email body
        $message  = "<h3>New {$formType}</h3>";
        $message .= "<p><strong>Name:</strong> " . esc($name) . "</p>";
        $message .= "<p><strong>Email:</strong> " . esc($emailId) . "</p>";
        $message .= "<p><strong>Phone:</strong> " . esc($phone) . "</p>";
        $message .= "<p><strong>Subject:</strong> " . esc($subject) . "</p>";
        $message .= "<p><strong>Message:</strong> " . nl2br(esc($messageContent)) . "</p>";

        $email->setMessage($message);

        if ($email->send()) {
            return true;
        } else {
            log_message('error', 'Generic form email failed to send: ' . $email->printDebugger(['headers']));
            return false;
        }
    }


    

    
    protected function sendPasswordResetEmail($userEmail, $password, $userProfileId)
    {
        // Initialize Email Service
        $email = Services::email();

        // Configure Email Preferences (optional if set in Config)
        $email->setFrom('your@gmail.com', 'fabrica distribution');
        $email->setTo($userEmail);

        // Email Subject
        $email->setSubject('Password Reset');

        // Compose Message
        $message  = 'Your account password has been successfully changed.<br>';
        $message .= 'Your username is: ' . esc($userEmail) . '<br>';
        $message .= 'Your password is: ' . esc($password) . '<br>';
        $message .= 'For security reasons, we recommend you reset your password immediately after logging in.';

        $email->setMessage($message);

        // Send Email
        if ($email->send()) {
            return true; // Email sent successfully
        } else {
            // Log the error for debugging
            log_message('error', 'Email failed to send: ' . $email->printDebugger(['headers']));
            return false; // Failed to send email
        }
    }

    protected function sendMailVerificationEmail($userEmail, $registrationCode)
    {
        // Initialize Email Service
        $email = Services::email();

        // Configure Email Preferences (optional if set in Config)
        $email->setFrom('your@gmail.com', 'fabrica distribution');
        $email->setTo($userEmail);

        // Email Subject
        $email->setSubject('Confirm Your Email Address: Your Registration Code Inside');

        // Compose Message
        $message  = 'Thank you for signing up! To complete your registration, we need to confirm your email address.<br>';
        $message .= 'Your registration code is: <br>';
        $message .= '<b>' . esc($registrationCode) . '</b><br>'; 
        $message .= 'Please enter this code in the app to verify your email address and complete your registration. <br><br>';
        $message .= 'If you did not request this, please ignore this email. <br>';

        $email->setMessage($message);

        // Send Email
        if ($email->send()) {
            return true; // Email sent successfully
        } else {
            // Log the error for debugging
            log_message('error', 'Email failed to send: ' . $email->printDebugger(['headers']));
            return false; // Failed to send email
        }
    }
}
