import api from './api';

export interface Province {
    id: number;
    code: string;
    name_th: string;
    name_en: string;
    geography_id: number;
}

export interface District {
    id: number;
    code: string;
    name_th: string;
    name_en: string;
    province_id: number;
}

export interface Subdistrict {
    id: number;
    zip_code: number;
    name_th: string;
    name_en: string;
    district_id: number;
}

export const masterApi = {
    getProvinces: async (): Promise<Province[]> => {
        const response = await api.get('/master/provinces');
        return response.data;
    },

    getDistricts: async (provinceId: number): Promise<District[]> => {
        const response = await api.get(`/master/provinces/${provinceId}/districts`);
        return response.data;
    },

    getSubdistricts: async (districtId: number): Promise<Subdistrict[]> => {
        const response = await api.get(`/master/districts/${districtId}/subdistricts`);
        return response.data;
    },

    getRubberTypes: async (): Promise<any[]> => {
        const response = await api.get('/master/rubber-types');
        return response.data;
    },
};
