import api from './index'
import type {ApiResponse} from './auth'

export interface PendingCardResponse {
  id: number
  cardCompany: string
  cardName: string
  annualFee: number
  cardType: string
  imageUrl: string | null
  description: string | null
  source: string
  status: string
  createdAt: string
  processedAt: string | null
}

export const pendingCardApi = {
  getPendingCards() {
    return api.get<ApiResponse<PendingCardResponse[]>>('/admin/pending-cards')
  },

  getPendingCount() {
    return api.get<ApiResponse<number>>('/admin/pending-cards/count')
  },

  approvePendingCard(id: number) {
    return api.post<ApiResponse<PendingCardResponse>>(`/admin/pending-cards/${id}/approve`)
  },

  rejectPendingCard(id: number) {
    return api.post<ApiResponse<PendingCardResponse>>(`/admin/pending-cards/${id}/reject`)
  },

  collectCards() {
    return api.post<ApiResponse<number>>('/admin/pending-cards/collect')
  },
}
