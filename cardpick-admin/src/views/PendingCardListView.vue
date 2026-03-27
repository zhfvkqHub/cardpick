<script setup lang="ts">
import {onMounted, ref} from 'vue'
import {pendingCardApi, type PendingCardResponse} from '../api/pendingCard'
import {ElMessage, ElMessageBox} from 'element-plus'

const pendingCards = ref<PendingCardResponse[]>([])
const loading = ref(false)
const processing = ref(false)
const collecting = ref(false)

async function fetchPendingCards() {
  loading.value = true
  try {
    const res = await pendingCardApi.getPendingCards()
    if (res.data.success && res.data.data) {
      pendingCards.value = res.data.data
    }
  } catch {
    ElMessage.error('대기 카드 목록을 불러오는데 실패했습니다')
  } finally {
    loading.value = false
  }
}

async function handleApprove(card: PendingCardResponse) {
  try {
    await ElMessageBox.confirm(
      `"${card.cardName}" 카드를 승인하시겠습니까? Card 테이블에 등록됩니다.`,
      '카드 승인',
      { confirmButtonText: '승인', cancelButtonText: '취소', type: 'info' },
    )
  } catch {
    return
  }
  processing.value = true
  try {
    await pendingCardApi.approvePendingCard(card.id)
    ElMessage.success('카드가 승인되었습니다')
    await fetchPendingCards()
  } catch (e: any) {
    const message = e.response?.data?.error?.message || '카드 승인에 실패했습니다'
    ElMessage.error(message)
  } finally {
    processing.value = false
  }
}

async function handleReject(card: PendingCardResponse) {
  try {
    await ElMessageBox.confirm(
      `"${card.cardName}" 카드를 반려하시겠습니까?`,
      '카드 반려',
      { confirmButtonText: '반려', cancelButtonText: '취소', type: 'warning' },
    )
  } catch {
    return
  }
  processing.value = true
  try {
    await pendingCardApi.rejectPendingCard(card.id)
    ElMessage.success('카드가 반려되었습니다')
    await fetchPendingCards()
  } catch (e: any) {
    const message = e.response?.data?.error?.message || '카드 반려에 실패했습니다'
    ElMessage.error(message)
  } finally {
    processing.value = false
  }
}

async function handleCollect() {
  collecting.value = true
  try {
    const res = await pendingCardApi.collectCards()
    if (res.data.success) {
      const count = res.data.data ?? 0
      ElMessage.success(`수집 완료: ${count}건의 신규 카드가 등록되었습니다`)
      await fetchPendingCards()
    }
  } catch (e: any) {
    const message = e.response?.data?.error?.message || '카드 수집에 실패했습니다'
    ElMessage.error(message)
  } finally {
    collecting.value = false
  }
}

function formatDate(dateStr: string) {
  return new Date(dateStr).toLocaleDateString('ko-KR', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  })
}

onMounted(fetchPendingCards)
</script>

<template>
  <div>
    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
      <h2 style="margin: 0;">신규 카드 후보</h2>
      <el-button type="primary" :loading="collecting" @click="handleCollect">
        <el-icon><Refresh /></el-icon>
        지금 수집
      </el-button>
    </div>

    <el-card shadow="hover">
      <el-table :data="pendingCards" v-loading="loading || processing" stripe style="width: 100%">
        <el-table-column prop="cardCompany" label="카드사" width="120" />
        <el-table-column prop="cardName" label="카드명" min-width="200" />
        <el-table-column prop="cardType" label="유형" width="80" />
        <el-table-column prop="annualFee" label="연회비" width="120">
          <template #default="{ row }">
            {{ row.annualFee.toLocaleString() }}원
          </template>
        </el-table-column>
        <el-table-column prop="source" label="출처" width="100">
          <template #default="{ row }">
            <el-tag size="small" type="info">{{ row.source }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createdAt" label="수집일" width="120">
          <template #default="{ row }">
            {{ formatDate(row.createdAt) }}
          </template>
        </el-table-column>
        <el-table-column label="관리" width="160" fixed="right">
          <template #default="{ row }">
            <el-button type="success" text size="small" @click="handleApprove(row)">
              승인
            </el-button>
            <el-button type="danger" text size="small" @click="handleReject(row)">
              반려
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <el-empty v-if="!loading && pendingCards.length === 0" description="대기 중인 카드가 없습니다" />
    </el-card>
  </div>
</template>
