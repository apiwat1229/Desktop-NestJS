import i18n from '@/i18n';
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

const t = i18n.global.t;

export const handleApiError = (error: ApiError, customMessage?: string): string => {
    let errorMessage = customMessage || t('errors.default');

    if (error.response) {
        // Server responded with error
        switch (error.response.status) {
            case 400:
                errorMessage = t('errors.invalidData');
                break;
            case 401:
                errorMessage = t('errors.loginAgain');
                break;
            case 403:
                errorMessage = t('errors.noPermission');
                break;
            case 404:
                errorMessage = t('errors.notFound');
                break;
            case 500:
                errorMessage = t('errors.serverError');
                break;
        }

        // Use server error message if available
        if (error.response.data?.message) {
            errorMessage = error.response.data.message;
        }
    } else if (error.request) {
        // Request made but no response
        errorMessage = t('errors.connectionFailed');
    }

    toast.error(errorMessage, {
        description: t('errors.tryAgain'),
    });

    console.error('API Error:', error);
    return errorMessage;
};
