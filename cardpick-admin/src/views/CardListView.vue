<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { cardApi, type CardResponse } from '../api/card'
import { ElMessage, ElMessageBox } from 'element-plus'

const router = useRouter()
const cards = ref<CardResponse[]>([])
const loading = ref(false)
const deleting = ref(false)
const keyword = ref('')

async function fetchCards() {
  loading.value = true
  try {
    const res = await cardApi.getCards(keyword.value || undefined)
    if (res.data.success && res.data.data) {
      cards.value = res.data.data
    }
  } catch {
    ElMessage.error('카드 목록을 불러오는데 실패했습니다')
  } finally {
    loading.value = false
  }
}

async function handleDelete(card: CardResponse) {
  try {
    await ElMessageBox.confirm(
      `"${card.cardName}" 카드를 삭제하시겠습니까?`,
      '카드 삭제',
      { confirmButtonText: '삭제', cancelButtonText: '취소', type: 'warning' },
    )
  } catch {
    // 취소 시 아무 동작 없음
    return
  }
  deleting.value = true
  try {
    await cardApi.deleteCard(card.id)
    ElMessage.success('카드가 삭제되었습니다')
    await fetchCards()
  } catch (e: any) {
    const message = e.response?.data?.error?.message || '카드 삭제에 실패했습니다'
    ElMessage.error(message)
  } finally {
    deleting.value = false
  }
}

onMounted(fetchCards)
</script>

<template>
  <div>
    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
      <h2 style="margin: 0;">카드 관리</h2>
      <el-button type="primary" @click="router.push('/cards/create')">
        <el-icon><Plus /></el-icon>
        카드 등록
      </el-button>
    </div>

    <el-card shadow="hover">
      <div style="margin-bottom: 16px;">
        <el-input
          v-model="keyword"
          placeholder="카드명 또는 카드사로 검색"
          clearable
          style="width: 300px;"
          @keyup.enter="fetchCards"
          @clear="fetchCards"
        >
          <template #append>
            <el-button @click="fetchCards">
              <el-icon><Search /></el-icon>
            </el-button>
          </template>
        </el-input>
      </div>

      <el-table :data="cards" v-loading="loading || deleting" stripe style="width: 100%">
        <el-table-column prop="id" label="ID" width="70" />
        <el-table-column prop="cardCompany" label="카드사" width="120" />
        <el-table-column prop="cardName" label="카드명" min-width="200" />
        <el-table-column prop="cardType" label="유형" width="80" />
        <el-table-column prop="annualFee" label="연회비" width="120">
          <template #default="{ row }">
            {{ row.annualFee.toLocaleString() }}원
          </template>
        </el-table-column>
        <el-table-column prop="benefitCount" label="혜택 수" width="90" />
        <el-table-column prop="isActive" label="상태" width="90">
          <template #default="{ row }">
            <el-tag :type="row.isActive ? 'success' : 'info'" size="small">
              {{ row.isActive ? '활성' : '비활성' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="관리" width="160" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" text size="small" @click="router.push(`/cards/${row.id}/edit`)">
              수정
            </el-button>
            <el-button type="danger" text size="small" @click="handleDelete(row)">
              삭제
            </el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>
