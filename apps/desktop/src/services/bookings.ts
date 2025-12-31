import api from './api';

export interface CreateBookingDto {
    date: string;
    startTime: string;
    endTime: string;
    supplierId: string;
    supplierCode: string;
    supplierName: string;
    truckType?: string;
    truckRegister?: string;
    rubberType: string;
    recorder: string;
}

export interface UpdateBookingDto extends Partial<CreateBookingDto> { }

export const bookingsApi = {
    getAll: async (params?: { date?: string; slot?: string; code?: string }) => {
        const response = await api.get('/bookings', { params });
        return response.data;
    },

    getById: async (id: string) => {
        const response = await api.get(`/bookings/${id}`);
        return response.data;
    },

    create: async (data: CreateBookingDto) => {
        const response = await api.post('/bookings', data);
        return response.data;
    },

    update: async (id: string, data: UpdateBookingDto) => {
        const response = await api.patch(`/bookings/${id}`, data);
        return response.data;
    },

    delete: async (id: string) => {
        const response = await api.delete(`/bookings/${id}`);
        return response.data;
    },

    checkIn: async (id: string, data?: any) => {
        const response = await api.patch(`/bookings/${id}/check-in`, data);
        return response.data;
    },

    startDrain: async (id: string) => {
        const response = await api.patch(`/bookings/${id}/start-drain`);
        return response.data;
    },

    stopDrain: async (id: string, data?: { note?: string }) => {
        const response = await api.patch(`/bookings/${id}/stop-drain`, data);
        return response.data;
    },

    saveWeightIn: async (id: string, data: any) => {
        const response = await api.patch(`/bookings/${id}/weight-in`, data);
        return response.data;
    },

    saveWeightOut: async (id: string, data: any) => {
        const response = await api.patch(`/bookings/${id}/weight-out`, data);
        return response.data;
    },
};
