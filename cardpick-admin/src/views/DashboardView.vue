<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { cardApi, type CardResponse } from '../api/card'

const totalCards = ref(0)
const activeCards = ref(0)
const recentCards = ref<CardResponse[]>([])
const loading = ref(false)

onMounted(async () => {
  loading.value = true
  try {
    const res = await cardApi.getCards()
    if (res.data.success && res.data.data) {
      const cards = res.data.data
      totalCards.value = cards.length
      activeCards.value = cards.filter((c) => c.isActive).length
      recentCards.value = cards
        .sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime())
        .slice(0, 5)
    }
  } catch {
    // handled by interceptor
  } finally {
    loading.value = false
  }
})
</script>

<template>
  <div>
    <h2 style="margin-top: 0;">대시보드</h2>

    <el-row :gutter="20" style="margin-bottom: 24px;">
      <el-col :span="8">
        <el-card shadow="hover">
          <el-statistic title="전체 카드 수" :value="totalCards">
            <template #prefix>
              <el-icon><CreditCard /></el-icon>
            </template>
          </el-statistic>
        </el-card>
      </el-col>
      <el-col :span="8">
        <el-card shadow="hover">
          <el-statistic title="활성 카드 수" :value="activeCards">
            <template #prefix>
              <el-icon><CircleCheck /></el-icon>
            </template>
          </el-statistic>
        </el-card>
      </el-col>
      <el-col :span="8">
        <el-card shadow="hover">
          <el-statistic title="비활성 카드 수" :value="totalCards - activeCards">
            <template #prefix>
              <el-icon><CircleClose /></el-icon>
            </template>
          </el-statistic>
        </el-card>
      </el-col>
    </el-row>

    <el-card shadow="hover">
      <template #header>
        <span>최근 등록된 카드</span>
      </template>
      <el-table :data="recentCards" v-loading="loading" stripe>
        <el-table-column prop="cardCompany" label="카드사" width="120" />
        <el-table-column prop="cardName" label="카드명" />
        <el-table-column prop="annualFee" label="연회비" width="120">
          <template #default="{ row }">
            {{ row.annualFee.toLocaleString() }}원
          </template>
        </el-table-column>
        <el-table-column prop="benefitCount" label="혜택 수" width="100" />
        <el-table-column prop="isActive" label="상태" width="100">
          <template #default="{ row }">
            <el-tag :type="row.isActive ? 'success' : 'info'">
              {{ row.isActive ? '활성' : '비활성' }}
            </el-tag>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>
