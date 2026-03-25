<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { cardApi, type BenefitResponse, type BenefitCreateRequest } from '../api/card'
import { ElMessage, ElMessageBox } from 'element-plus'

const router = useRouter()
const route = useRoute()
const loading = ref(false)
const saving = ref(false)

const isEdit = computed(() => !!route.params.id)
const cardId = computed(() => Number(route.params.id))

const form = reactive({
  cardCompany: '',
  cardName: '',
  annualFee: 0,
  minimumSpending: null as number | null,
  cardType: '신용',
  imageUrl: '',
  description: '',
  isActive: true,
})

const benefits = ref<BenefitResponse[]>([])

const benefitForm = reactive<BenefitCreateRequest>({
  category: '',
  benefitType: '할인',
  benefitRate: 0,
  benefitLimit: null,
  minimumAmount: null,
  description: '',
})

const showBenefitDialog = ref(false)
const editingBenefitId = ref<number | null>(null)

const cardCompanies = ['신한', '삼성', 'KB국민', '현대', '롯데', '우리', '하나', 'NH농협', 'BC', '씨티']
const cardTypes = ['신용', '체크']
const categories = ['식비', '교통', '통신', '쇼핑', '편의점', '카페', '주유', '문화', '여행', '의료', '교육', '기타']
const benefitTypes = ['할인', '적립', '캐시백']

onMounted(async () => {
  if (isEdit.value) {
    loading.value = true
    try {
      const res = await cardApi.getCard(cardId.value)
      if (res.data.success && res.data.data) {
        const card = res.data.data
        form.cardCompany = card.cardCompany
        form.cardName = card.cardName
        form.annualFee = card.annualFee
        form.minimumSpending = card.minimumSpending
        form.cardType = card.cardType
        form.imageUrl = card.imageUrl || ''
        form.description = card.description || ''
        form.isActive = card.isActive
        benefits.value = card.benefits
      }
    } catch {
      ElMessage.error('카드 정보를 불러오는데 실패했습니다')
      router.push('/cards')
    } finally {
      loading.value = false
    }
  }
})

async function handleSubmit() {
  if (!form.cardCompany || !form.cardName || !form.cardType) {
    ElMessage.warning('필수 항목을 입력해주세요')
    return
  }
  saving.value = true
  try {
    const data = {
      ...form,
      imageUrl: form.imageUrl || null,
      description: form.description || null,
    }
    if (isEdit.value) {
      await cardApi.updateCard(cardId.value, { ...data, isActive: form.isActive })
    } else {
      await cardApi.createCard(data)
    }
    ElMessage.success(isEdit.value ? '카드가 수정되었습니다' : '카드가 등록되었습니다')
    router.push('/cards')
  } catch (e: any) {
    const message = e.response?.data?.error?.message || '저장에 실패했습니다'
    ElMessage.error(message)
  } finally {
    saving.value = false
  }
}

function openBenefitDialog(benefit?: BenefitResponse) {
  if (benefit) {
    editingBenefitId.value = benefit.id
    benefitForm.category = benefit.category
    benefitForm.benefitType = benefit.benefitType
    benefitForm.benefitRate = benefit.benefitRate
    benefitForm.benefitLimit = benefit.benefitLimit
    benefitForm.minimumAmount = benefit.minimumAmount
    benefitForm.description = benefit.description || ''
  } else {
    editingBenefitId.value = null
    benefitForm.category = ''
    benefitForm.benefitType = '할인'
    benefitForm.benefitRate = 0
    benefitForm.benefitLimit = null
    benefitForm.minimumAmount = null
    benefitForm.description = ''
  }
  showBenefitDialog.value = true
}

async function handleSaveBenefit() {
  if (!benefitForm.category || !benefitForm.benefitType || !benefitForm.benefitRate) {
    ElMessage.warning('필수 항목을 입력해주세요')
    return
  }
  try {
    if (editingBenefitId.value) {
      const res = await cardApi.updateBenefit(editingBenefitId.value, { ...benefitForm })
      if (res.data.success && res.data.data) {
        const idx = benefits.value.findIndex((b) => b.id === editingBenefitId.value)
        if (idx >= 0) benefits.value[idx] = res.data.data
      }
      ElMessage.success('혜택이 수정되었습니다')
    } else {
      const res = await cardApi.createBenefit(cardId.value, { ...benefitForm })
      if (res.data.success && res.data.data) {
        benefits.value.push(res.data.data)
      }
      ElMessage.success('혜택이 등록되었습니다')
    }
    showBenefitDialog.value = false
  } catch {
    ElMessage.error('혜택 저장에 실패했습니다')
  }
}

async function handleDeleteBenefit(benefit: BenefitResponse) {
  try {
    await ElMessageBox.confirm('이 혜택을 삭제하시겠습니까?', '혜택 삭제', {
      confirmButtonText: '삭제',
      cancelButtonText: '취소',
      type: 'warning',
    })
    await cardApi.deleteBenefit(benefit.id)
    benefits.value = benefits.value.filter((b) => b.id !== benefit.id)
    ElMessage.success('혜택이 삭제되었습니다')
  } catch (e: any) {
    if (e !== 'cancel') {
      ElMessage.error('혜택 삭제에 실패했습니다')
    }
  }
}
</script>

<template>
  <div v-loading="loading">
    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
      <h2 style="margin: 0;">{{ isEdit ? '카드 수정' : '카드 등록' }}</h2>
      <el-button @click="router.push('/cards')">목록으로</el-button>
    </div>

    <el-card shadow="hover" style="margin-bottom: 20px;">
      <template #header><span>카드 정보</span></template>
      <el-form label-width="120px" style="max-width: 600px;">
        <el-form-item label="카드사" required>
          <el-select v-model="form.cardCompany" placeholder="카드사 선택" style="width: 100%;">
            <el-option v-for="c in cardCompanies" :key="c" :label="c" :value="c" />
          </el-select>
        </el-form-item>
        <el-form-item label="카드명" required>
          <el-input v-model="form.cardName" placeholder="카드명 입력" />
        </el-form-item>
        <el-form-item label="카드 유형" required>
          <el-radio-group v-model="form.cardType">
            <el-radio v-for="t in cardTypes" :key="t" :value="t">{{ t }}</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="연회비">
          <el-input-number v-model="form.annualFee" :min="0" :step="1000" />
        </el-form-item>
        <el-form-item label="전월 실적">
          <el-input-number v-model="form.minimumSpending" :min="0" :step="10000" />
        </el-form-item>
        <el-form-item label="이미지 URL">
          <el-input v-model="form.imageUrl" placeholder="https://..." />
        </el-form-item>
        <el-form-item label="설명">
          <el-input v-model="form.description" type="textarea" :rows="3" placeholder="카드 설명" />
        </el-form-item>
        <el-form-item label="활성 상태" v-if="isEdit">
          <el-switch v-model="form.isActive" active-text="활성" inactive-text="비활성" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" :loading="saving" @click="handleSubmit">
            {{ isEdit ? '수정' : '등록' }}
          </el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- Benefits section (edit mode only) -->
    <el-card v-if="isEdit" shadow="hover">
      <template #header>
        <div style="display: flex; justify-content: space-between; align-items: center;">
          <span>혜택 목록</span>
          <el-button type="primary" size="small" @click="openBenefitDialog()">
            <el-icon><Plus /></el-icon>
            혜택 추가
          </el-button>
        </div>
      </template>
      <el-table :data="benefits" stripe>
        <el-table-column prop="category" label="카테고리" width="120" />
        <el-table-column prop="benefitType" label="혜택 유형" width="100" />
        <el-table-column prop="benefitRate" label="혜택율(%)" width="100" />
        <el-table-column prop="benefitLimit" label="한도(원)" width="120">
          <template #default="{ row }">
            {{ row.benefitLimit ? row.benefitLimit.toLocaleString() + '원' : '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="description" label="설명" min-width="200" />
        <el-table-column label="관리" width="140" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" text size="small" @click="openBenefitDialog(row)">수정</el-button>
            <el-button type="danger" text size="small" @click="handleDeleteBenefit(row)">삭제</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- Benefit Dialog -->
    <el-dialog v-model="showBenefitDialog" :title="editingBenefitId ? '혜택 수정' : '혜택 추가'" width="500px">
      <el-form label-width="100px">
        <el-form-item label="카테고리" required>
          <el-select v-model="benefitForm.category" placeholder="카테고리 선택" style="width: 100%;">
            <el-option v-for="c in categories" :key="c" :label="c" :value="c" />
          </el-select>
        </el-form-item>
        <el-form-item label="혜택 유형" required>
          <el-radio-group v-model="benefitForm.benefitType">
            <el-radio v-for="t in benefitTypes" :key="t" :value="t">{{ t }}</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="혜택율(%)" required>
          <el-input-number v-model="benefitForm.benefitRate" :min="0" :max="100" :step="0.5" :precision="2" />
        </el-form-item>
        <el-form-item label="한도(원)">
          <el-input-number v-model="benefitForm.benefitLimit" :min="0" :step="1000" />
        </el-form-item>
        <el-form-item label="최소 금액(원)">
          <el-input-number v-model="benefitForm.minimumAmount" :min="0" :step="1000" />
        </el-form-item>
        <el-form-item label="설명">
          <el-input v-model="benefitForm.description" type="textarea" :rows="2" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showBenefitDialog = false">취소</el-button>
        <el-button type="primary" @click="handleSaveBenefit">저장</el-button>
      </template>
    </el-dialog>
  </div>
</template>
