import { LightningElement, track } from 'lwc';
import logoAsset from '@salesforce/resourceUrl/Ramky_Logo';
import bgAsset from '@salesforce/resourceUrl/Skybackground';
import getUserValidation from '@salesforce/apex/Customer_Login.getUserValidation';
import loginIssue from '@salesforce/apex/Customer_Login.loginIssue';
import verifyOTP from '@salesforce/apex/Customer_Login.verifyOTP';
import verifiedIcon from '@salesforce/resourceUrl/verifiedIcon';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
export default class RamkyLogin extends LightningElement {
    @track email = '';
    logoUrl = logoAsset;
    emailverify = verifiedIcon;
    bgImageUrl = bgAsset;
    @track customerMessage = '';
    @track isError = false;
    @track isSuccess = false;
    otpPage = false;
    showHome = true;
    @track isSubmitting = false;
    @track submitted = false;
    dashBoardPage = false;
    @track errorMessage = '';
    @track messageClass = 'error-message';
    @track isTimerExpired = false;
    @track timer;
    @track timeLeft = 120; // 2 mins = 120 seconds

    // This Method is used on Customer Login Screen BackGround Image CSS....
    get backgroundStyle() {
        return `background-image: url(${this.bgImageUrl});
               position: fixed;
    top: 0;
    left: 0;
    width: 100vw;
    height: 100vh;
    background-size: cover;
    background-position: center;
    display: flex;
    justify-content: center;
    align-items: center;`;
    }

    handleEmailChange(event) {
        debugger;
        this.email = event.target.value;
    }

    handleGetOtp() {
        debugger;
        console.log('OTP sent to:', this.email);
    }
    handleEmailLoginValidation() {
        getUserValidation({ email: this.email })
            .then((result) => {
                if (result === 'Customer Found') {
                    this.customerMessage = '✅ Customer Found!';
                    this.otpPage = true;
                    this.startTimer();
                } else {
                    this.customerMessage = result === 'Customer Not Found'
                        ? '❌ Customer not found for the entered Email.'
                        : '⚠️ An error occurred during validation.';
                    this.otpPage = false;
                    const evt = new ShowToastEvent({
                        title: this.customerMessage,
                        variant:'error'
                    })
                    this.dispatchEvent(evt);
                    console.log('LOGIN MESSAGE =' + this.customerMessage);
                }
            })
            .catch((error) => {
                this.customerMessage = '⚠️ Unexpected server error.';
                this.otpPage = false;
                console.error('Validation error:', error);
            });
    }


    @track otpInputs = Array(6).fill('');
    otp = '';

    @track otpInputs = Array(6).fill('');
    value;
    handleInput(event) {
        const index = parseInt(event.target.dataset.index, 10);
        this.value = event.target.value;

        const onlyNumber = this.value.replace(/\D/g, ''); // Removes non-numeric

        if (onlyNumber.length === 1) {
            this.otpInputs[index] = onlyNumber;
            this.errorMessage = ''; // Clear any previous error

            // Move to next input
            const next = this.template.querySelector(`input[data-index="${index + 1}"]`);
            if (next) next.focus();
        } else {
            this.otpInputs[index] = '';
            if (this.value && isNaN(this.value)) {
                this.errorMessage = '❌ Please enter only numeric values.';
            }
        }
    }


    handleKeyDown(event) {
        const index = parseInt(event.target.dataset.index, 10);
        const value = event.target.value;

        if (event.key === 'Backspace') {
            if (value === '') {
                if (index > 0) {
                    const prev = this.template.querySelector(`input[data-index="${index - 1}"]`);
                    if (prev) {
                        prev.focus();
                        this.otpInputs[index - 1] = '';
                    }
                }
            } else {
                if (value === '') {
                    if (index > 0) {
                        const prev = this.template.querySelector(`input[data-index="${index - 1}"]`);
                        if (prev) {
                            prev.focus();
                            this.otpInputs[index - 1] = '';
                        }
                    }
                }
            }
        }
    }





    handleVerify() {
        const otp = this.otpInputs.join('');
        console.log('Entered OTP:', otp);

    }

    handleBack() {
        this.email = null;
        this.otpPage = false;
        this.value = null;
        this.otpInputs = new Array(6).fill(''); 
        clearInterval(this.timer);
        this.isTimerExpired = false;
    }
    handleResendOtp() {
        this.startTimer();
        this.handleEmailLoginValidation();
        this.otpInputs = new Array(6).fill('');
        this.errorMessage = '';
    }
    startTimer() {
        this.isTimerExpired = false;
        this.timeLeft = 120;
        clearInterval(this.timer);

        this.timer = setInterval(() => {
            if (this.timeLeft > 0) {
                this.timeLeft--;
            } else {
                clearInterval(this.timer);
                this.isTimerExpired = true;
            }
        }, 1000);
    }
    get formattedTime() {
        const mins = Math.floor(this.timeLeft / 60);
        const secs = this.timeLeft % 60;
        return `${mins}:${secs < 10 ? '0' + secs : secs}`;
    }
    handleValidateOTP() {
        const otp = this.otpInputs.join('');

        verifyOTP({ otp: parseInt(otp), email: this.email })
            .then(result => {
                if (result === 'Valid') {
                    this.isSuccess = true;
                    this.isError = false;
                    setTimeout(() => {
                        this.dashBoardPage = true;
                        console.log('Proceeding to system login...');
                    }, 3000);
                } else {
                    this.isSuccess = false;
                    this.isError = true;
                    this.errorMessage = 'Invalid OTP. Please try again.';
                }
            })
            .catch(error => {
                this.isSuccess = false;
                this.isError = true;
                this.errorMessage = 'An unexpected error occurred.';
                console.error(error);
            });
    }

    handleIssue() {
        this.showHome = false;
    }
    // handleBack() {
    //     this.showHome = true;
    // }

    handleInputChange(event) {
        const { name, value } = event.target;
        this[name] = value;
    }
    caseEmail;
    casePhone;
    caseDescription;
    handleCaseEmail(event) {
        this.caseEmail = event.target.value;

    }
    handleCasePhone(event) {
        this.casePhone = event.target.value;
    }
    handleDescription(event) {
        this.caseDescription = event.target.value;
    }

    handleSubmit() {
        this.isSubmitting = true;
        this.errorMessage = '';

        loginIssue({
            email: this.caseEmail,
            phone: this.casePhone,
            description: this.caseDescription
        }).then(() => {
            this.submitted = true;
            this.isSubmitting = false;
        }).catch(error => {
            this.errorMessage = error.body?.message || 'Something went wrong.';
            this.isSubmitting = false;
        });
    }


}