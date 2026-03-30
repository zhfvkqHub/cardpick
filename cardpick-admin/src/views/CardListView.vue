<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { cardApi, type CardResponse, type CardImportItem, type CardImportResult } from '../api/card'
import { ElMessage, ElMessageBox } from 'element-plus'

const router = useRouter()
const cards = ref<CardResponse[]>([])
const loading = ref(false)
const deleting = ref(false)
const keyword = ref('')

// JSON 임포트
const importDialogVisible = ref(false)
const importJson = ref('')
const importing = ref(false)
const importResult = ref<CardImportResult | null>(null)

const JSON_EXAMPLE = JSON.stringify([
  {
    cardCompany: '신한',
    cardName: '딥드림카드',
    annualFee: 15000,
    minimumSpending: 300000,
    cardType: '신용',
    description: '카드 설명',
    benefits: [
      { categoryGroup: 'FOOD', benefitType: '적립', benefitRate: 2.0, description: '식비 2% 적립' },
      { categoryGroup: 'CAFE', category: 'CAFE_STARBUCKS', benefitType: '할인', benefitRate: 10.0, benefitLimit: 5000 },
    ],
  },
], null, 2)

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

async function handleClone(card: CardResponse) {
  try {
    await ElMessageBox.confirm(
      `"${card.cardName}" 카드를 복제하시겠습니까?`,
      '카드 복제',
      { confirmButtonText: '복제', cancelButtonText: '취소', type: 'info' },
    )
  } catch {
    return
  }
  try {
    const res = await cardApi.cloneCard(card.id)
    if (res.data.success && res.data.data) {
      ElMessage.success(`"${res.data.data.cardName}" 카드가 복제됐습니다`)
      await fetchCards()
    }
  } catch (e: any) {
    const message = e.response?.data?.error?.message || '카드 복제에 실패했습니다'
    ElMessage.error(message)
  }
}

function openImportDialog() {
  importJson.value = ''
  importResult.value = null
  importDialogVisible.value = true
}

async function handleImport() {
  let parsed: CardImportItem[]
  try {
    parsed = JSON.parse(importJson.value)
    if (!Array.isArray(parsed)) throw new Error()
  } catch {
    ElMessage.error('올바른 JSON 배열 형식이 아닙니다')
    return
  }
  importing.value = true
  importResult.value = null
  try {
    const res = await cardApi.importCards(parsed)
    if (res.data.success && res.data.data) {
      importResult.value = res.data.data
      if (res.data.data.failedCount === 0) {
        ElMessage.success(`${res.data.data.successCount}개 카드가 등록됐습니다`)
        importDialogVisible.value = false
        await fetchCards()
      } else {
        await fetchCards()
      }
    }
  } catch (e: any) {
    const message = e.response?.data?.error?.message || 'JSON 임포트에 실패했습니다'
    ElMessage.error(message)
  } finally {
    importing.value = false
  }
}

onMounted(fetchCards)
</script>

<template>
  <div>
    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
      <h2 style="margin: 0;">카드 관리</h2>
      <div style="display: flex; gap: 8px;">
        <el-button @click="openImportDialog">
          <el-icon><Upload /></el-icon>
          JSON 임포트
        </el-button>
        <el-button type="primary" @click="router.push('/cards/create')">
          <el-icon><Plus /></el-icon>
          카드 등록
        </el-button>
      </div>
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
        <el-table-column label="관리" width="200" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" text size="small" @click="router.push(`/cards/${row.id}/edit`)">
              수정
            </el-button>
            <el-button type="success" text size="small" @click="handleClone(row)">
              복제
            </el-button>
            <el-button type="danger" text size="small" @click="handleDelete(row)">
              삭제
            </el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- JSON 임포트 다이얼로그 -->
    <el-dialog v-model="importDialogVisible" title="카드 JSON 일괄 임포트" width="700px" :close-on-click-modal="false">
      <div style="margin-bottom: 8px; font-size: 13px; color: #666;">
        아래 형식으로 JSON을 입력하세요.
        <el-button type="primary" link size="small" @click="importJson = JSON_EXAMPLE">예시 불러오기</el-button>
      </div>
      <el-input
        v-model="importJson"
        type="textarea"
        :rows="16"
        placeholder="JSON 배열을 입력하세요"
        style="font-family: monospace; font-size: 12px;"
      />

      <!-- 임포트 결과 -->
      <div v-if="importResult" style="margin-top: 16px;">
        <el-alert
          :title="`완료: ${importResult.successCount}개 성공, ${importResult.failedCount}개 실패`"
          :type="importResult.failedCount === 0 ? 'success' : 'warning'"
          :closable="false"
          show-icon
        />
        <el-table v-if="importResult.failed.length > 0" :data="importResult.failed" size="small" style="margin-top: 8px;">
          <el-table-column prop="cardName" label="카드명" />
          <el-table-column prop="reason" label="실패 사유" />
        </el-table>
      </div>

      <template #footer>
        <el-button @click="importDialogVisible = false">닫기</el-button>
        <el-button type="primary" :loading="importing" @click="handleImport">
          임포트 실행
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>
