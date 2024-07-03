<template>
  <div class="login-page">
    <div class="login-section">
      <div class="video-bg">
        <div class="title">小肥路书</div>
        <video
          autoplay
          muted
          playsinline
          loop
          src="https://prod-streaming-video-msn-com.akamaized.net/5660e39e-db67-4092-aaf9-4e30fb518271/4b10e349-a6f0-455f-b0b4-66b216abaa68.mp4"
          poster="https://img-s-msn-com.akamaized.net/tenant/amp/entityid/AA12PJGx.img"
        ></video>
      </div>
      <div class="login-panel text-a_c">
        <router-view></router-view>
      </div>
    </div>
  </div>
</template>
<script setup lang="ts"></script>
<style lang="stylus">
.login-page{
  height: 100%;
  l-flex v c c;
  flex-grow: 1;

  .login-section{
    l-wh: 90vw calc(90vw/(16/9)) var(--maz-border-radius);
    max-width: 1440px;
    max-height: calc(1440px/(16/9));
    background: var(--maz-color-bg);
    color: var(--maz-color-text)
    l-mh: auto;
    box-shadow: yoz_shadow.ph;
    overflow: hidden;
    position relative;
    l-flex h l c;
  }

  .video-bg{
    position: relative;
    flex: 1;
    height: 100%;
    border-radius: var(--maz-border-radius);
    overflow: hidden;
    video{
      l-flex: h c c;
      position: absolute;
      -webkit-box-pack: center;
      box-sizing: border-box;
      object-fit: cover;
      l-wh: 100%;
      padding: 0;
      margin: 0;
    }
    .title{
      l-abs: 0 30%;
      l-wh: 100% 100px;
      t-fl: 6em 2 center;
      font-weight: bolder;
      color: #fff;
      text-shadow: 0 5px 10px rgba(0,0,0,.2);
      z-index: 1;
    }
  }

  .login-panel{
    l-wh: 400px auto 50px;
    padding: 20px 40px;
    form{
      display: flex;
      flex-direction: column;
      gap: 24px;
    }
  }
}

@media screen and (max-width: 768px) {
  .login-page {
    flex-grow: 1;
    height: 0;
    .login-section{
      position static;
      width: 100%;
      l-flex v c c;
      flex-grow: 1;
      height: 100%;
      height: 0;
      border-radius: 0;
      overflow: visible
      .video-bg{
        l-abs 0 0 'lt'
        l-wh: 100% 100%;
        border-radius: 0;
        .title{
          l-abs: 0 3%;
          l-wh: 100% 80px;
          t-fl: 4em 2 center;
          color: #fff;
        }
      }
    }
    .login-panel{
      l-wh: 400px auto var(--maz-border-radius);
      max-width 90vw;
      box-shadow: yoz_shadow.ph;
      background: var(--maz-color-bg);
      padding: 30px 20px;
      position: relative;
      form{
        display: flex;
        flex-direction: column;
        gap: 24px;
      }
    }
  }
}
</style>
