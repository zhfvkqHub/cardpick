<script setup lang="ts">
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import { ElMessage } from 'element-plus'

const router = useRouter()
const authStore = useAuthStore()
const loading = ref(false)

const form = reactive({
  loginId: '',
  password: '',
})

async function handleLogin() {
  if (!form.loginId || !form.password) {
    ElMessage.warning('아이디와 비밀번호를 입력해주세요')
    return
  }
  loading.value = true
  try {
    await authStore.login(form)
    router.push('/')
  } catch (e: any) {
    const message = e.response?.data?.error?.message || e.message || '로그인에 실패했습니다'
    ElMessage.error(message)
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="login-container">
    <el-card class="login-card" shadow="always">
      <template #header>
        <h2 style="margin: 0; text-align: center;">CardPick 관리자 로그인</h2>
      </template>
      <el-form @submit.prevent="handleLogin">
        <el-form-item label="아이디">
          <el-input v-model="form.loginId" placeholder="관리자 아이디" :prefix-icon="User" />
        </el-form-item>
        <el-form-item label="비밀번호">
          <el-input v-model="form.password" type="password" placeholder="비밀번호" :prefix-icon="Lock" show-password @keyup.enter="handleLogin" />
        </el-form-item>
        <el-button type="primary" :loading="loading" style="width: 100%" @click="handleLogin">
          로그인
        </el-button>
      </el-form>
    </el-card>
  </div>
</template>

<script lang="ts">
import { User, Lock } from '@element-plus/icons-vue'
export default {
  components: { User, Lock },
}
</script>

<style scoped>
.login-container {
  height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: #304156;
}
.login-card {
  width: 400px;
}
</style>
