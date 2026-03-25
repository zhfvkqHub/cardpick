import api from './index'
import type { ApiResponse } from './auth'

export interface CardResponse {
  id: number
  cardCompany: string
  cardName: string
  annualFee: number
  minimumSpending: number | null
  cardType: string
  imageUrl: string | null
  description: string | null
  isActive: boolean
  benefitCount: number
  createdAt: string
  updatedAt: string
}

export interface BenefitResponse {
  id: number
  category: string
  benefitType: string
  benefitRate: number
  benefitLimit: number | null
  minimumAmount: number | null
  description: string | null
}

export interface CardDetailResponse extends Omit<CardResponse, 'benefitCount'> {
  benefits: BenefitResponse[]
}

export interface CardCreateRequest {
  cardCompany: string
  cardName: string
  annualFee: number
  minimumSpending?: number | null
  cardType: string
  imageUrl?: string | null
  description?: string | null
}

export interface CardUpdateRequest extends CardCreateRequest {
  isActive: boolean
}

export interface BenefitCreateRequest {
  category: string
  benefitType: string
  benefitRate: number
  benefitLimit?: number | null
  minimumAmount?: number | null
  description?: string | null
}

export interface BenefitUpdateRequest extends BenefitCreateRequest {}

export const cardApi = {
  getCards(keyword?: string) {
    return api.get<ApiResponse<CardResponse[]>>('/admin/cards', {
      params: keyword ? { keyword } : {},
    })
  },

  getCard(id: number) {
    return api.get<ApiResponse<CardDetailResponse>>(`/admin/cards/${id}`)
  },

  createCard(data: CardCreateRequest) {
    return api.post<ApiResponse<CardResponse>>('/admin/cards', data)
  },

  updateCard(id: number, data: CardUpdateRequest) {
    return api.put<ApiResponse<CardResponse>>(`/admin/cards/${id}`, data)
  },

  deleteCard(id: number) {
    return api.delete<ApiResponse<void>>(`/admin/cards/${id}`)
  },

  createBenefit(cardId: number, data: BenefitCreateRequest) {
    return api.post<ApiResponse<BenefitResponse>>(`/admin/cards/${cardId}/benefits`, data)
  },

  updateBenefit(benefitId: number, data: BenefitUpdateRequest) {
    return api.put<ApiResponse<BenefitResponse>>(`/admin/cards/benefits/${benefitId}`, data)
  },

  deleteBenefit(benefitId: number) {
    return api.delete<ApiResponse<void>>(`/admin/cards/benefits/${benefitId}`)
  },
}
