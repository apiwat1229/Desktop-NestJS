import { toast } from 'vue-sonner';

export interface ApiError {
    response?: {
        status: number;
        data?: {
            message?: string;
        };
    };
    request?: any;
    message?: string;
}

export const handleApiError = (error: ApiError, customMessage?: string): string => {
    let errorMessage = customMessage || 'เกิดข้อผิดพลาด กรุณาลองใหม่';

    if (error.response) {
        // Server responded with error
        switch (error.response.status) {
            case 400:
                errorMessage = 'ข้อมูลไม่ถูกต้อง กรุณาตรวจสอบอีกครั้ง';
                break;
            case 401:
                errorMessage = 'กรุณาเข้าสู่ระบบใหม่';
                break;
            case 403:
                errorMessage = 'คุณไม่มีสิทธิ์ในการดำเนินการนี้';
                break;
            case 404:
                errorMessage = 'ไม่พบข้อมูลที่ต้องการ';
                break;
            case 500:
                errorMessage = 'เกิดข้อผิดพลาดที่เซิร์ฟเวอร์';
                break;
        }

        // Use server error message if available
        if (error.response.data?.message) {
            errorMessage = error.response.data.message;
        }
    } else if (error.request) {
        // Request made but no response
        errorMessage = 'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้';
    }

    toast.error(errorMessage, {
        description: 'กรุณาลองใหม่อีกครั้ง',
    });

    console.error('API Error:', error);
    return errorMessage;
};
