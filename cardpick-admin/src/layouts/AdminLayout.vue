<script setup lang="ts">
import {onMounted, ref} from 'vue'
import {useRoute, useRouter} from 'vue-router'
import {useAuthStore} from '../stores/auth'
import {pendingCardApi} from '../api/pendingCard'

const router = useRouter()
const route = useRoute()
const authStore = useAuthStore()
const pendingCount = ref(0)

async function fetchPendingCount() {
  try {
    const res = await pendingCardApi.getPendingCount()
    if (res.data.success && res.data.data != null) {
      pendingCount.value = res.data.data
    }
  } catch {
    // ignore
  }
}

onMounted(fetchPendingCount)

function handleLogout() {
  authStore.logout()
  router.push('/login')
}
</script>

<template>
  <el-container style="height: 100vh">
    <el-aside width="220px" style="background-color: #304156">
      <div style="padding: 20px; text-align: center; color: #fff; font-size: 18px; font-weight: bold;">
        CardPick Admin
      </div>
      <el-menu
        :default-active="route.path"
        background-color="#304156"
        text-color="#bfcbd9"
        active-text-color="#409eff"
        router
      >
        <el-menu-item index="/">
          <el-icon><DataAnalysis /></el-icon>
          <span>대시보드</span>
        </el-menu-item>
        <el-menu-item index="/pending-cards">
          <el-icon><Bell /></el-icon>
          <span>신규 카드 후보</span>
          <el-badge v-if="pendingCount > 0" :value="pendingCount" :max="99" style="margin-left: 8px;" />
        </el-menu-item>
        <el-menu-item index="/cards">
          <el-icon><CreditCard /></el-icon>
          <span>카드 관리</span>
        </el-menu-item>
      </el-menu>
    </el-aside>

    <el-container>
      <el-header style="display: flex; align-items: center; justify-content: flex-end; border-bottom: 1px solid #e6e6e6; background: #fff;">
        <el-button type="danger" text @click="handleLogout">
          <el-icon><SwitchButton /></el-icon>
          로그아웃
        </el-button>
      </el-header>

      <el-main style="background-color: #f5f7fa;">
        <router-view />
      </el-main>
    </el-container>
  </el-container>
</template>
